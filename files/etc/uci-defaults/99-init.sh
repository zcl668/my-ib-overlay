#!/bin/sh

# 设置默认wan口防火墙打开，方便虚拟机用户首次访问 webui
uci set firewall.@zone[1].input='ACCEPT'
uci commit firewall

# 检查 dockerd 是否已安装 设置防火墙规则 让docker的子网扩大范围 '172.16.0.0/12'
if command -v dockerd >/dev/null 2>&1; then
    echo "检测到 Docker，正在配置防火墙规则..."
    FW_FILE="/etc/config/firewall"

    # 删除所有名为 docker 的 zone
    uci delete firewall.docker

    # 先获取所有 forwarding 索引，倒序排列删除
    for idx in $(uci show firewall | grep "=forwarding" | cut -d[ -f2 | cut -d] -f1 | sort -rn); do
        src=$(uci get firewall.@forwarding[$idx].src 2>/dev/null)
        dest=$(uci get firewall.@forwarding[$idx].dest 2>/dev/null)
        echo "Checking forwarding index $idx: src=$src dest=$dest"
        if [ "$src" = "docker" ] || [ "$dest" = "docker" ]; then
            echo "Deleting forwarding @forwarding[$idx]"
            uci delete firewall.@forwarding[$idx]
        fi
    done
    # 提交删除
    uci commit firewall
    # 追加新的 zone + forwarding 配置
    cat <<EOF >>"$FW_FILE"

config zone 'docker'
  option input 'ACCEPT'
  option output 'ACCEPT'
  option forward 'ACCEPT'
  option name 'docker'
  list subnet '172.16.0.0/12'

config forwarding
  option src 'docker'
  option dest 'lan'

config forwarding
  option src 'docker'
  option dest 'wan'

config forwarding
  option src 'lan'
  option dest 'docker'
EOF

else
    echo "未检测到 Docker，跳过防火墙配置。"
fi

# 设置主机名映射，解决安卓原生TV首次连不上网的问题
uci add dhcp domain
uci set "dhcp.@domain[-1].name=time.android.com"
uci set "dhcp.@domain[-1].ip=203.107.6.88"
uci commit dhcp

# 单网口采用dhcp模式，ip需要在上级路由器查询
# 多网口则是一般的路由器模式 lan口ip地址是192.168.99.1 wan口是自动获取模式
count=0
for iface in $(ls /sys/class/net | grep -v lo); do
    if [ -e /sys/class/net/$iface/device ] && [[ $iface == eth* || $iface == en* ]]; then
        count=$((count + 1))
    fi
done

if [ "$count" -eq 1 ]; then
    echo "Detected single Ethernet interface, configuring LAN as DHCP"
    uci set network.lan.proto='dhcp'
    uci commit network
elif [ "$count" -gt 1 ]; then
    echo "Multiple Ethernet interfaces found, keeping LAN static IP"
    uci set network.lan.ipaddr='192.168.99.1'
    uci commit network
fi

exit 0
