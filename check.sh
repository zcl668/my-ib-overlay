#!/bin/bash

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"
output_file="packages_names.txt"
> "$output_file"
for cmd in tar file; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}❌ 缺少命令：$cmd，请先安装（如 apt install tar）${RESET}"
        exit 1
    fi
done

echo -e "${YELLOW}📦 开始扫描 packages/ 目录下所有 .ipk 包...${RESET}"

for ipk in packages/*.ipk; do
    [ -f "$ipk" ] || continue
    pkgname=""
    basename=$(basename "$ipk")
    filetype=$(file -b "$ipk")
    

    if echo "$filetype" | grep -q "gzip compressed data"; then
        tmpdir=$(mktemp -d)
        cp "$ipk" "$tmpdir/pkg.tar.gz"
        tar -xzf "$tmpdir/pkg.tar.gz" -C "$tmpdir" 2>/dev/null
        if [ -f "$tmpdir/control.tar.gz" ]; then
            
            tar -xzf "$tmpdir/control.tar.gz" -C "$tmpdir" 2>/dev/null
            control_path=$(find "$tmpdir" -type f -name control | head -n 1)
            if [ -n "$control_path" ]; then
                pkgname=$(grep "^Package:" "$control_path" 2>/dev/null | cut -d ' ' -f 2)
            else
                echo "    ⚠️ control 文件未找到"
            fi
        fi

        rm -rf "$tmpdir"
    else
        echo "    ⚠️ 文件类型不支持"
    fi

    if [ -z "$pkgname" ]; then
        guessed=$(echo "$basename" | cut -d '_' -f1)
        echo -e "${YELLOW}⚠️  未能解析包名，猜测：$guessed${RESET}"
    else
        echo -e "${GREEN}✅  $pkgname${RESET}"
        echo "$pkgname" >> "$output_file"
    fi
done
