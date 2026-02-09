#!/bin/bash

# This script integrates the HD2312 DVB driver.
# It handles both the driver source and the necessary kernel configurations.

# 1. Clone HD2312 driver source
if [ ! -d "hd2312" ]; then
    git clone https://github.com/hanwckf/hd2312
fi

# 2. Setup DVB core and USB support modules definition
mkdir -p package/kernel/linux/modules
cp hd2312/openwrt/dvb.mk package/kernel/linux/modules/dvb.mk

# 3. Setup HD2312 package definition
mkdir -p package/hd2312
cp hd2312/openwrt/Makefile package/hd2312/Makefile

# 4. Enable HD2312 in generic and target-specific kernel config
# We search for all config-6.* files in the likely locations.
for f in target/linux/generic/config-6.* target/linux/mediatek/filogic/config-6.*; do
    if [ -e "$f" ]; then
        echo "Patching kernel config: $f"
        cat hd2312/openwrt/dvb-kconfig >> "$f"
    fi
done

echo "HD2312 integration completed."
