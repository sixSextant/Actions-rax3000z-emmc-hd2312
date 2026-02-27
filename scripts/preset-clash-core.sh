#!/bin/bash
set -e

# 预置openclash内核
CORE_DIR="files/etc/openclash/core"
mkdir -p "$CORE_DIR"

# 下载并验证函数
download_and_extract() {
    local url=$1
    local target_file=$2
    local type=$3 # tar or gz
    local final_name=$4
    local retries=5
    local count=0
    local tmp_file="tmp_core_$(date +%s%N)"

    while [ $count -lt $retries ]; do
        echo "Downloading $url (Attempt $((count+1))/$retries)..."
        if curl -L -s --connect-timeout 30 --retry 3 "$url" -o "$tmp_file"; then
            # 验证文件是否为空
            if [ ! -s "$tmp_file" ]; then
                echo "Error: Downloaded file is empty."
            # 验证 gzip 完整性
            elif ! gzip -t "$tmp_file" > /dev/null 2>&1; then
                echo "Error: Downloaded file is not a valid gzip archive."
            else
                # 提取
                if [ "$type" = "tar" ]; then
                    if tar -xOzf "$tmp_file" > "$CORE_DIR/$final_name"; then
                        rm -f "$tmp_file"
                        return 0
                    fi
                elif [ "$type" = "gz" ]; then
                    if gunzip -c "$tmp_file" > "$CORE_DIR/$final_name"; then
                        rm -f "$tmp_file"
                        return 0
                    fi
                fi
                echo "Error: Extraction failed."
            fi
        fi
        count=$((count + 1))
        sleep 5
    done
    rm -f "$tmp_file"
    echo "Failed to process $url after $retries attempts."
    return 1
}

# dev内核 (tar.gz)
download_and_extract "https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux-arm64.tar.gz" "clash" "tar" "clash"

# premium内核 (.gz)
download_and_extract "https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux-arm64-2023.08.17-13-gdcc8d87.gz" "clash_tun" "gz" "clash_tun"

# Meta内核版本 (tar.gz)
download_and_extract "https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-arm64.tar.gz" "clash_meta" "tar" "clash_meta"

# 给内核权限
chmod +x "$CORE_DIR"/clash*

# GeoIP.dat 和 GeoSite.dat
mkdir -p files/etc/openclash
curl -L -s --retry 5 "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat" -o files/etc/openclash/GeoIP.dat
curl -L -s --retry 5 "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" -o files/etc/openclash/GeoSite.dat

# Country.mmdb
curl -L -s --retry 5 "https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/lite/Country.mmdb" -o files/etc/openclash/Country.mmdb
