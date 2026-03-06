#!/bin/bash
set -e

# This script integrates XR30 eMMC support using Kiddin9's device definitions
# Optimized for ImmortalWrt 24.10 (Kernel 6.6)

# 1. Download DTS files from Kiddin9's Kwrt repository
# Placing in the standard dts directory
DTS_DIR="target/linux/mediatek/dts"
mkdir -p ${DTS_DIR}

KIDDIN9_DTS_URL="https://raw.githubusercontent.com/kiddin9/Kwrt/master/devices/mediatek_filogic/diy/target/linux/mediatek/dts"

# Download the main DTS file
wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dts -O ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts

# Download the DTSI file
DTSI_FILE="${DTS_DIR}/mt7981b-cmcc-xr30.dtsi"
if ! wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30.dtsi -O "$DTSI_FILE"; then
    echo "Warning: mt7981b-cmcc-xr30.dtsi not found, trying -emmc suffix"
    DTSI_FILE="${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dtsi"
    if ! wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dtsi -O "$DTSI_FILE"; then
         echo "Error: Could not download DTSI file"
         exit 1
    fi
fi

if [ ! -s "${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts" ]; then
    echo "Error: mt7981b-cmcc-xr30-emmc.dts is empty or not found"
    exit 1
fi

# Patch DTSI for compatibility with Kernel 6.6 in ImmortalWrt 24.10
# The include path should be relative to the dts directory or use the <...> format
sed -i '/\/dts-v1\/;/d' "$DTSI_FILE"
sed -i 's/#include "mt7981.dtsi"/#include <arm64\/mediatek\/mt7981.dtsi>/g' "$DTSI_FILE"

# 2. Add Device definition to filogic.mk
# Defining independently to avoid artifact mismatches from RAX3000M
# We use standard FIT image targets for eMMC
cat << 'EOF' >> target/linux/mediatek/image/filogic.mk

define Device/cmcc_xr30-emmc
  DEVICE_VENDOR := CMCC
  DEVICE_MODEL := XR30 (eMMC)
  DEVICE_DTS := mt7981b-cmcc-xr30-emmc
  DEVICE_DTS_DIR := ../dts
  SUPPORTED_DEVICES := cmcc,xr30-emmc cmcc,rax3000m-emmc
  DEVICE_PACKAGES := kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware kmod-usb3 \
	automount f2fsck mkf2fs arm-trusted-firmware-mediatek-mt7981-emmc-ddr4 uboot-mediatek-mt7981_cmcc_rax3000m-emmc
  KERNEL_LOADADDR := 0x44000000
  KERNEL := kernel-bin | gzip
  KERNEL_INITRAMFS := kernel-bin | lzma | \
	fit lzma $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb with-initrd | pad-to 64k
  KERNEL_INITRAMFS_SUFFIX := -recovery.itb
  IMAGES := sysupgrade.itb
  IMAGE_SIZE := $$(shell expr 64 + $$(CONFIG_TARGET_ROOTFS_PARTSIZE))m
  IMAGE/sysupgrade.itb := append-kernel | \
	fit gzip $$(KDIR)/image-$$(firstword $$(DEVICE_DTS)).dtb external-static-with-rootfs | \
	pad-rootfs | append-metadata
  ARTIFACTS := emmc-gpt.bin
  ARTIFACT/emmc-gpt.bin := mt798x-gpt emmc
endef
TARGET_DEVICES += cmcc_xr30-emmc
EOF

# 3. Add runtime identification
# 02_network
if [ -f "target/linux/mediatek/filogic/base-files/etc/board.d/02_network" ]; then
    grep -q "cmcc,xr30-emmc" target/linux/mediatek/filogic/base-files/etc/board.d/02_network || \
    sed -i 's/cmcc,rax3000m|/cmcc,rax3000m|cmcc,xr30-emmc|/g' target/linux/mediatek/filogic/base-files/etc/board.d/02_network
fi
# platform.sh
if [ -f "target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh" ]; then
    grep -q "cmcc,xr30-emmc" target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh || \
    sed -i 's/cmcc,rax3000m|/cmcc,rax3000m|cmcc,xr30-emmc|/g' target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh
fi
