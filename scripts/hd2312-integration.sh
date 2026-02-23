#!/bin/bash
set -e

# This script is called from the 'openwrt' directory

# Clone HD2312 driver source
if [ ! -d "hd2312" ]; then
    git clone --depth 1 https://github.com/hanwckf/hd2312
fi

# Setup DVB core and USB support modules definition
# Using -n to avoid overwriting if the user has custom ones, or just overwrite if it's the expected way
cp -f hd2312/openwrt/dvb.mk package/kernel/linux/modules/dvb.mk

# Setup HD2312 package definition
mkdir -p package/hd2312
cp -f hd2312/openwrt/Makefile package/hd2312/Makefile

# Enable HD2312 in kernel configs (kernel 6.x)
# Apply to generic configs
for f in target/linux/generic/config-6.*; do
    if [ -f "$f" ]; then
        if ! grep -q "CONFIG_DVB_HD2312" "$f"; then
            echo "" >> "$f"
            cat hd2312/openwrt/dvb-kconfig >> "$f"
        fi
    fi
done

# Apply to mediatek target configs
for f in target/linux/mediatek/filogic/config-6.*; do
    if [ -f "$f" ]; then
        if ! grep -q "CONFIG_DVB_HD2312" "$f"; then
            echo "" >> "$f"
            cat hd2312/openwrt/dvb-kconfig >> "$f"
        fi
    fi
done
