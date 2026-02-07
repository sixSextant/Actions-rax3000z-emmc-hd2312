#!/bin/bash

# This script integrates XR30 eMMC support using Kiddin9's device definitions
# which are more complete for 24.10 and Kernel 6.6.

# 1. Download DTS files from Kiddin9's Kwrt repository
DTS_DIR="target/linux/mediatek/dts"
KIDDIN9_DTS_URL="https://raw.githubusercontent.com/kiddin9/Kwrt/master/devices/mediatek_filogic/diy/target/linux/mediatek/dts"

wget ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dts -O ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts
wget ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30.dtsi -O ${DTS_DIR}/mt7981b-cmcc-xr30.dtsi

# 2. Add Device definition to filogic.mk
# We inherit from Device/cmcc_rax3000m_common but customize for XR30.
# We explicitly set KERNEL_IN_UBI to empty for eMMC.
# We also ensure the artifacts point to the rax3000m-emmc bootloaders since they are hardware-identical.
cat << 'EOF' >> target/linux/mediatek/image/filogic.mk

define Device/cmcc_xr30-emmc
  DEVICE_VENDOR := CMCC
  DEVICE_MODEL := XR30 (eMMC)
  DEVICE_DTS := mt7981b-cmcc-xr30-emmc
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek
  SUPPORTED_DEVICES := cmcc,xr30-emmc cmcc,rax3000m-emmc
  $(call Device/cmcc_rax3000m_common)
  KERNEL_IN_UBI :=
  ARTIFACTS += emmc-preloader.bin emmc-bl31-uboot.fip
  ARTIFACT/emmc-preloader.bin := mt7981-bl2 emmc-ddr4
  ARTIFACT/emmc-bl31-uboot.fip := mt7981-bl31-uboot cmcc_rax3000m-emmc
endef
TARGET_DEVICES += cmcc_xr30-emmc
EOF

# 3. Add runtime identification
# 02_network
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/etc/board.d/02_network
# platform.sh
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh
