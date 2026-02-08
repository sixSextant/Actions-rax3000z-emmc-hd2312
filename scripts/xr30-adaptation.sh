#!/bin/bash

# This script integrates XR30 eMMC support.
# Since we are using padavanonly/immortalwrt-mt798x-6.6,
# it likely has a similar structure to the official ImmortalWrt.

DTS_DIR="target/linux/mediatek/dts"
# We'll use the official Kiddin9 DTS as it's verified for LEDs.
KIDDIN9_DTS_URL="https://raw.githubusercontent.com/kiddin9/Kwrt/master/devices/mediatek_filogic/diy/target/linux/mediatek/dts"

echo "Downloading XR30 DTS files..."
wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dts -O ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts
wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30.dtsi -O ${DTS_DIR}/mt7981b-cmcc-xr30.dtsi

# Fix include in DTS if needed (sometimes Kiddin9 uses absolute-like includes)
sed -i 's|#include "mt7981.dtsi"|#include <arm64/mediatek/mt7981.dtsi>|g' ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts 2>/dev/null || true

# Add Device definition to filogic.mk
# We append it to the end of the file.
# Note: We REMOVE DEVICE_DTS_DIR to let it use the default (target/linux/mediatek/dts)
cat << 'EOF' >> target/linux/mediatek/image/filogic.mk

define Device/cmcc_xr30-emmc
  DEVICE_VENDOR := CMCC
  DEVICE_MODEL := XR30 (eMMC)
  DEVICE_DTS := mt7981b-cmcc-xr30-emmc
  SUPPORTED_DEVICES := cmcc,xr30-emmc
  DEVICE_PACKAGES := kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware kmod-usb3 automount f2fsck mkf2fs
  KERNEL_LOADADDR := 0x44000000
  KERNEL := kernel-bin | gzip
  KERNEL_INITRAMFS := kernel-bin | gzip | fit gzip $$(KDIR)/image-$$(DEVICE_DTS).dtb
  IMAGES := sysupgrade.itb
  IMAGE/sysupgrade.itb := append-kernel | fit gzip $$(KDIR)/image-$$(DEVICE_DTS).dtb external-static-with-rootfs | append-metadata
  ARTIFACTS += emmc-preloader.bin emmc-bl31-uboot.fip
  ARTIFACT/emmc-preloader.bin := mt7981-bl2 emmc-ddr4
  ARTIFACT/emmc-bl31-uboot.fip := mt7981-bl31-uboot cmcc_rax3000m-emmc
endef
TARGET_DEVICES += cmcc_xr30-emmc
EOF

# Runtime identification
# 02_network
[ -f target/linux/mediatek/filogic/base-files/etc/board.d/02_network ] && \
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/etc/board.d/02_network

# platform.sh
[ -f target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh ] && \
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh
