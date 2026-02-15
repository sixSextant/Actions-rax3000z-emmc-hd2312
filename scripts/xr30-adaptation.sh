#!/bin/bash

# This script integrates XR30 eMMC support using Kiddin9's device definitions
# which are more complete for Kernel 6.6.

# 1. Download DTS files from Kiddin9's Kwrt repository
# Placing them in target/linux/mediatek/dts and setting DEVICE_DTS_DIR := ../dts
DTS_DIR="target/linux/mediatek/dts"
KIDDIN9_DTS_URL="https://raw.githubusercontent.com/kiddin9/Kwrt/master/devices/mediatek_filogic/diy/target/linux/mediatek/dts"

wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dts -O ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts
wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30.dtsi -O ${DTS_DIR}/mt7981b-cmcc-xr30.dtsi

# Patch include paths for Kernel 6.6 compatibility
# Change local include to kernel-tree include
sed -i 's/#include "mt7981.dtsi"/#include <arm64\/mediatek\/mt7981.dtsi>/g' ${DTS_DIR}/mt7981b-cmcc-xr30*

# 2. Add Device definition to filogic.mk
# We inherit from cmcc_rax3000m which is very similar to XR30.
# We also include the ATF/U-Boot packages in DEVICE_PACKAGES to ensure they are built.
cat << 'EOF' >> target/linux/mediatek/image/filogic.mk

define Device/cmcc_xr30-emmc
  $(call Device/cmcc_rax3000m)
  DEVICE_MODEL := XR30 (eMMC)
  DEVICE_DTS := mt7981b-cmcc-xr30-emmc
  DEVICE_DTS_DIR := ../dts
  SUPPORTED_DEVICES := cmcc,xr30-emmc cmcc,rax3000m-emmc
  DEVICE_PACKAGES += arm-trusted-firmware-mediatek-mt7981-emmc-ddr4 uboot-mediatek-mt7981_cmcc_rax3000m-emmc
endef
TARGET_DEVICES += cmcc_xr30-emmc
EOF

# 3. Add runtime identification
# 02_network
sed -i 's/rax3000m|/rax3000m|cmcc,xr30-emmc|/g' target/linux/mediatek/filogic/base-files/etc/board.d/02_network
# platform.sh
sed -i 's/rax3000m|/rax3000m|cmcc,xr30-emmc|/g' target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh
