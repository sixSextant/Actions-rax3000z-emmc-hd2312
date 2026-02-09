#!/bin/bash

# This script integrates XR30 eMMC support for the padavanonly/immortalwrt-mt798x-6.6 source.
# This source uses a kernel overlay directory structure for MT798x Kernel 6.6.

# Correct path for Kernel 6.6 DTS overlay in this repository
DTS_DIR="target/linux/mediatek/files-6.6/arch/arm64/boot/dts/mediatek"
mkdir -p $DTS_DIR

KIDDIN9_DTS_URL="https://raw.githubusercontent.com/kiddin9/Kwrt/master/devices/mediatek_filogic/diy/target/linux/mediatek/dts"

echo "Downloading XR30 DTS files to kernel overlay..."
wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dts -O ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts
wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30.dtsi -O ${DTS_DIR}/mt7981b-cmcc-xr30.dtsi

# Adjust includes for the kernel source structure
# In the kernel tree, mt7981.dtsi is in the same directory.
sed -i 's|#include "mt7981.dtsi"|#include "mt7981.dtsi"|g' ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts
sed -i 's|#include <arm64/mediatek/mt7981.dtsi>|#include "mt7981.dtsi"|g' ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts

# Add Device definition to filogic.mk
# Since the DTS is now in the kernel tree, we don't need DEVICE_DTS_DIR.
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
[ -f target/linux/mediatek/filogic/base-files/etc/board.d/02_network ] && \
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/etc/board.d/02_network

[ -f target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh ] && \
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh
