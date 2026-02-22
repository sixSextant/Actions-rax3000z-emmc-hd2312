#!/bin/bash

# This script is called from the 'openwrt' directory

# Clone HD2312 driver source
git clone https://github.com/hanwckf/hd2312

# Setup DVB core and USB support modules definition
cp hd2312/openwrt/dvb.mk package/kernel/linux/modules/dvb.mk

# Setup HD2312 package definition
mkdir -p package/hd2312
cp hd2312/openwrt/Makefile package/hd2312/Makefile

# Enable HD2312 in generic kernel config (kernel 6.x)
for f in target/linux/generic/config-6.*; do
    [ -f "$f" ] && cat hd2312/openwrt/dvb-kconfig >> "$f"
done
