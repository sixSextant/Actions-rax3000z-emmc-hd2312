#!/bin/bash

# This script is called from the 'openwrt' directory

# Download DTS files from Kiddin9's Kwrt
# These files are needed for the XR30 eMMC version to fix LEDs and eMMC support
DTS_PATH="target/linux/mediatek/dts"
curl -sL https://raw.githubusercontent.com/kiddin9/Kwrt/25.12/devices/mediatek_filogic/diy/target/linux/mediatek/dts/mt7981b-cmcc-xr30-emmc.dts -o $DTS_PATH/mt7981b-cmcc-xr30-emmc.dts
curl -sL https://raw.githubusercontent.com/kiddin9/Kwrt/25.12/devices/mediatek_filogic/diy/target/linux/mediatek/dts/mt7981b-cmcc-xr30.dts -o $DTS_PATH/mt7981b-cmcc-xr30.dts
curl -sL https://raw.githubusercontent.com/kiddin9/Kwrt/25.12/devices/mediatek_filogic/diy/target/linux/mediatek/dts/mt7981b-cmcc-xr30.dtsi -o $DTS_PATH/mt7981b-cmcc-xr30.dtsi

# Fix include path: Kwrt uses mt7981b.dtsi, ImmortalWrt 24.10 uses mt7981.dtsi
sed -i 's/mt7981b.dtsi/mt7981.dtsi/' $DTS_PATH/mt7981b-cmcc-xr30.dtsi

# Update board definitions for network and sysupgrade
# Use precise matching with | to avoid mangling other variants like rax3000m-emmc
# 02_network
sed -i 's/cmcc,rax3000m|/cmcc,rax3000m|\\\n\tcmcc,xr30-emmc|/' target/linux/mediatek/filogic/base-files/etc/board.d/02_network

# platform.sh
sed -i 's/cmcc,rax3000m|/cmcc,rax3000m|\\\n\tcmcc,xr30-emmc|/' target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh

# Add XR30 eMMC device definition to filogic.mk
# We match RAX3000M's common configuration for ImmortalWrt 24.10
# We explicitly set IMAGES and clear ARTIFACTS to avoid dependencies on external bootloader files (BL2/FIP)
# which caused build failures in previous attempts.
cat >> target/linux/mediatek/image/filogic.mk <<EOF

define Device/cmcc_xr30-emmc
  DEVICE_VENDOR := CMCC
  DEVICE_MODEL := XR30 eMMC (RAX3000Z增强版)
  DEVICE_DTS := mt7981b-cmcc-xr30-emmc
  \$(call Device/cmcc_rax3000m_common)
  DEVICE_DTS_OVERLAY :=
  IMAGES := sysupgrade.itb
  ARTIFACTS :=
endef
TARGET_DEVICES += cmcc_xr30-emmc
EOF
