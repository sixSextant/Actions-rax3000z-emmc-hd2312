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
# Append cmcc,xr30-emmc after cmcc,rax3000m to ensure correct identification
# 02_network
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/etc/board.d/02_network

# platform.sh
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh

# Add XR30 eMMC device definition to filogic.mk
# We define it from scratch to avoid KERNEL_IN_UBI from cmcc_rax3000m_common
cat >> target/linux/mediatek/image/filogic.mk <<EOF

define Device/cmcc_xr30-emmc
  DEVICE_VENDOR := CMCC
  DEVICE_MODEL := XR30 eMMC (RAX3000Z增强版)
  DEVICE_DTS := mt7981b-cmcc-xr30-emmc
  DEVICE_DTS_DIR := ../dts
  DEVICE_DTC_FLAGS := --pad 4096
  DEVICE_DTS_LOADADDR := 0x43f00000
  DEVICE_PACKAGES := kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware kmod-usb3 \\
	automount f2fsck mkf2fs
  KERNEL_LOADADDR := 0x44000000
  KERNEL := kernel-bin | gzip
  KERNEL_INITRAMFS := kernel-bin | lzma | \\
	fit lzma \$(KDIR)/image-\$(firstword \$(DEVICE_DTS)).dtb with-initrd | pad-to 64k
  KERNEL_INITRAMFS_SUFFIX := -recovery.itb
  IMAGES := sysupgrade.itb
  IMAGE_SIZE := \$(shell expr 64 + \$(CONFIG_TARGET_ROOTFS_PARTSIZE))m
  IMAGE/sysupgrade.itb := append-kernel | \\
	fit gzip \$(KDIR)/image-\$(firstword \$(DEVICE_DTS)).dtb external-static-with-rootfs | \\
	pad-rootfs | append-metadata
  SUPPORTED_DEVICES := cmcc,xr30-emmc cmcc,rax3000m
  ARTIFACTS :=
endef
TARGET_DEVICES += cmcc_xr30-emmc
EOF
