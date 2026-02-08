#!/bin/bash

# This script integrates the HD2312 DVB driver into the OpenWrt source tree.
# It handles both the driver source and the necessary kernel configurations.

# 1. Clone HD2312 driver source
if [ ! -d "hd2312" ]; then
    git clone https://github.com/hanwckf/hd2312
fi

# 2. Setup DVB core and USB support modules definition
# This file contains the Kmod definitions for DVB support.
mkdir -p package/kernel/linux/modules
cp hd2312/openwrt/dvb.mk package/kernel/linux/modules/dvb.mk

# 3. Setup HD2312 package definition
mkdir -p package/hd2312
cp hd2312/openwrt/Makefile package/hd2312/Makefile

# 4. Enable HD2312 in generic kernel config
# We apply it to all config-6.x files found in the generic target.
for f in target/linux/generic/config-6.*; do
    [ -e "$f" ] && cat hd2312/openwrt/dvb-kconfig >> "$f"
done

# Also apply to the mediatek target specifically to be sure
for f in target/linux/mediatek/filogic/config-6.*; do
    [ -e "$f" ] && cat hd2312/openwrt/dvb-kconfig >> "$f"
done

echo "HD2312 integration completed."
