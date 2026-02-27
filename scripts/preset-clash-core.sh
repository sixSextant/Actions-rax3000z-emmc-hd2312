#!/bin/bash
set -e

# 预置openclash内核
CORE_DIR="files/etc/openclash/core"
mkdir -p "$CORE_DIR"

# 下载函数
download_file() {
    local url=$1
    local output=$2
    local retries=3
    local count=0
    while [ $count -lt $retries ]; do
        if curl -L -s --connect-timeout 20 --retry 5 "$url" -o "$output"; then
            if [ -s "$output" ]; then
                return 0
            fi
        fi
        count=$((count + 1))
        echo "Download failed, retrying ($count/$retries)..."
        sleep 5
    done
    echo "Failed to download $url"
    return 1
}

# dev内核 (tar.gz)
CLASH_DEV_URL="https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux-arm64.tar.gz"
download_file "$CLASH_DEV_URL" "clash_dev.tar.gz"
tar -xOzf clash_dev.tar.gz > "$CORE_DIR/clash"
rm -f clash_dev.tar.gz

# premium内核 (.gz)
CLASH_TUN_URL="https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux-arm64-2023.08.17-13-gdcc8d87.gz"
download_file "$CLASH_TUN_URL" "clash_tun.gz"
gunzip -c clash_tun.gz > "$CORE_DIR/clash_tun"
rm -f clash_tun.gz

# Meta内核版本 (tar.gz)
CLASH_META_URL="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-arm64.tar.gz"
download_file "$CLASH_META_URL" "clash_meta.tar.gz"
tar -xOzf clash_meta.tar.gz > "$CORE_DIR/clash_meta"
rm -f clash_meta.tar.gz

# 给内核权限
chmod +x "$CORE_DIR"/clash*

# GeoIP.dat 和 GeoSite.dat
mkdir -p files/etc/openclash
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
download_file "$GEOIP_URL" "files/etc/openclash/GeoIP.dat"
download_file "$GEOSITE_URL" "files/etc/openclash/GeoSite.dat"

# Country.mmdb
COUNTRY_LITE_URL="https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/lite/Country.mmdb"
download_file "$COUNTRY_LITE_URL" "files/etc/openclash/Country.mmdb"
