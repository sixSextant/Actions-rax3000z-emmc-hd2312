#!/bin/bash

# This script integrates XR30 eMMC support using Kiddin9's device definitions.
# These definitions include the correct LED (GPIO 34/35) and eMMC controller nodes for 24.10.

DTS_DIR="target/linux/mediatek/dts"
KIDDIN9_DTS_URL="https://raw.githubusercontent.com/kiddin9/Kwrt/master/devices/mediatek_filogic/diy/target/linux/mediatek/dts"

# 1. Download DTS files from Kiddin9's Kwrt repository
# These files are verified to contain the correct LED and eMMC nodes.
wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dts -O ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts
wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30.dtsi -O ${DTS_DIR}/mt7981b-cmcc-xr30.dtsi

# 2. Add Device definition to filogic.mk
# We use a flattened definition to avoid complex FIT configurations that break some custom U-Boots.
# Note: KERNEL_IN_UBI is NOT set here because eMMC does not use UBI.
cat << 'EOF' >> target/linux/mediatek/image/filogic.mk

define Device/cmcc_xr30-emmc
  DEVICE_VENDOR := CMCC
  DEVICE_MODEL := XR30 (eMMC)
  DEVICE_DTS := mt7981b-cmcc-xr30-emmc
  SUPPORTED_DEVICES := cmcc,xr30-emmc cmcc,rax3000m-emmc
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

# 3. Add runtime identification
# 02_network
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/etc/board.d/02_network
# platform.sh
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh
