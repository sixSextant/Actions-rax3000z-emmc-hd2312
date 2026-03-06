#!/bin/bash
set -e

# 预置openclash内核
# 经过对 OpenClash 'core' 分区的在线检索，确认以下路径为 2025/2026 年可用的有效下载地址。
# 注意：原有的 dev 和 premium 内核已在远程库中移除或移动。
CORE_DIR="files/etc/openclash/core"
mkdir -p "$CORE_DIR"

# 下载并验证函数
download_and_extract() {
    local url=$1
    local type=$2 # tar or gz
    local final_name=$3
    local retries=5
    local count=0
    local tmp_file="tmp_core_$(date +%s%N)"

    while [ $count -lt $retries ]; do
        echo "Downloading $url (Attempt $((count+1))/$retries)..."
        # 使用 curl -L 处理重定向，并设置合理的超时
        if curl -L -s --connect-timeout 30 --retry 3 "$url" -o "$tmp_file"; then
            # 验证文件是否为空且是有效的 gzip
            if [ -s "$tmp_file" ] && gzip -t "$tmp_file" > /dev/null 2>&1; then
                # 提取
                if [ "$type" = "tar" ]; then
                    tar -xOzf "$tmp_file" > "$CORE_DIR/$final_name"
                elif [ "$type" = "gz" ]; then
                    gunzip -c "$tmp_file" > "$CORE_DIR/$final_name"
                fi

                if [ -s "$CORE_DIR/$final_name" ]; then
                    rm -f "$tmp_file"
                    chmod +x "$CORE_DIR/$final_name"
                    echo "Successfully installed $final_name"
                    return 0
                fi
            fi
        fi
        echo "Warning: Download or verification failed for $url, retrying..."
        count=$((count + 1))
        sleep 5
    done
    rm -f "$tmp_file"
    echo "Error: Failed to process $url after $retries attempts."
    return 1
}

# Meta (Mihomo) 内核 - 核心版本
# 路径经 API 验证有效: https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz
download_and_extract "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz" "tar" "clash_meta"

# Smart 内核 - 备选核心
# 路径经 API 验证有效: https://raw.githubusercontent.com/vernesong/OpenClash/core/master/smart/clash-linux-arm64.tar.gz
download_and_extract "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/smart/clash-linux-arm64.tar.gz" "tar" "clash"

# 设置兼容性软链接
cd "$CORE_DIR"
[ -f clash_meta ] && [ ! -f clash_tun ] && ln -s clash_meta clash_tun
cd - > /dev/null

# GeoIP.dat 和 GeoSite.dat
mkdir -p files/etc/openclash
curl -L -s --retry 5 "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat" -o files/etc/openclash/GeoIP.dat
curl -L -s --retry 5 "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" -o files/etc/openclash/GeoSite.dat

# Country.mmdb
curl -L -s --retry 5 "https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/lite/Country.mmdb" -o files/etc/openclash/Country.mmdb
