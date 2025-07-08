#!/bin/sh

# 先执行 prepare-packages.sh 此脚本用于拷贝所有自定义ipk到packages目录
sh prepare-packages.sh
# 仓库内的包名
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES -dnsmasq"
PACKAGES="$PACKAGES dnsmasq-full"
PACKAGES="$PACKAGES luci"
PACKAGES="$PACKAGES bash"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-compat"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-i18n-base-zh-cn"
PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"

# 使用条件:在extra-packages下放置了相关ipk或run
# 这是自定义的包 你可以用#注释掉不需要的包 也可以添加更多的包 
CUSTOM_PACKAGES=""
# 文件传输 luci-app-filetransfer
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-lib-fs"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-lua-runtime"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-filetransfer"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-filetransfer-zh-cn"
# 第三方软件 主题 luci-theme-argon 紫色主题 3个ipk
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-argon"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-argon-config-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-argon-config"
# 第三方插件 openclash 内核放在files/etc/openclash/core/clash_meta
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash"
# 第三方插件 luci-app-passwall 包含内部组件
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-passwall"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-passwall-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES geoview"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES sing-box"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES hysteria"
# 第三方插件 luci-app-ssr-plus 尤其注意要包含 shadowsocks-libev-ss-server
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-ssr-plus"
# 第三方插件 luci-app-homeproxy
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-homeproxy-zh-cn"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-homeproxy"
# 第三方插件 luci-app-adguardhome 去广告
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-adguardhome"
# istore 应用商店
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-store"
# 首页和网络向导
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-quickstart"
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-quickstart-zh-cn"

# ✅ 校验 CUSTOM_PACKAGES 中的包是否都存在于 packages_names.txt
package_file="packages_names.txt"
for pkg in $CUSTOM_PACKAGES; do
  if ! grep -qx "$pkg" "$package_file"; then
    echo "❌ 错误：包 $pkg 不存在于 $package_file 中 请检查自定义包名是否正确!"
    exit 1
  fi
done

# 拼接
PACKAGES="$PACKAGES $CUSTOM_PACKAGES"

# 若构建openclash 则添加内核
if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
    echo "✅ [构建逻辑] 已选择 luci-app-openclash，添加 openclash core"
    mkdir -p files/etc/openclash/core
    cp extra-packages/temp-unpack/clash_meta files/etc/openclash/core/clash_meta
else
    echo "❌ [构建逻辑] 未选择 luci-app-openclash"
    if [ -d files/etc/openclash ]; then
      rm -rf files/etc/openclash
    fi
fi

# 若构建luci-app-adguardhome 则添加内核
if echo "$PACKAGES" | grep -q "luci-app-adguardhome"; then
    echo "✅ [构建逻辑] 已选择 luci-app-adguardhome，添加 AdGuardHome core"
    cp extra-packages/temp-unpack/AdGuardHome/AdGuardHome files/usr/bin/AdGuardHome
else
    echo "❌ [构建逻辑] 未选择 luci-app-adguardhome"
    if [ -f files/usr/bin/AdGuardHome ]; then
      rm -rf files/usr/bin/AdGuardHome
    fi
fi

# 开始构建 软件包大小1024代表1GB 
# 可选参数FILES=files 代表files目录中若有文件 则覆盖openwrt的根目录 原样注入  
# 例如files/etc对应覆盖openwrt系统/etc目录中的文件 
# 例如files/mnt对应覆盖openwrt系统/mnt目录中的文件 

make image PROFILE=generic PACKAGES="$PACKAGES"  FILES=files ROOTFS_PARTSIZE=1024


