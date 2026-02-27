#!/bin/bash
set -e

# This script integrates XR30 eMMC support using Kiddin9's device definitions
# which are more complete for Kernel 6.6.

# 1. Download DTS files from Kiddin9's Kwrt repository
# The correct location is the kernel overlay directory.
if [ -d "target/linux/mediatek/files-6.6" ]; then
    DTS_DIR="target/linux/mediatek/files-6.6/arch/arm64/boot/dts/mediatek"
elif [ -d "target/linux/mediatek/files-6.1" ]; then
    DTS_DIR="target/linux/mediatek/files-6.1/arch/arm64/boot/dts/mediatek"
else
    DTS_DIR="target/linux/mediatek/files/arch/arm64/boot/dts/mediatek"
fi
mkdir -p ${DTS_DIR}
KIDDIN9_DTS_URL="https://raw.githubusercontent.com/kiddin9/Kwrt/master/devices/mediatek_filogic/diy/target/linux/mediatek/dts"

# Download the main DTS file
wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dts -O ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts

# Download the DTSI file
# Try to download the standard name first
DTSI_FILE="${DTS_DIR}/mt7981b-cmcc-xr30.dtsi"
if ! wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30.dtsi -O "$DTSI_FILE"; then
    echo "Warning: mt7981b-cmcc-xr30.dtsi not found, trying -emmc suffix"
    DTSI_FILE="${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dtsi"
    if ! wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dtsi -O "$DTSI_FILE"; then
         echo "Error: Could not download mt7981b-cmcc-xr30.dtsi or mt7981b-cmcc-xr30-emmc.dtsi"
         exit 1
    fi
fi

if [ ! -s "${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts" ]; then
    echo "Error: mt7981b-cmcc-xr30-emmc.dts is empty or not found"
    exit 1
fi

# Patch DTSI for compatibility
if [ -f "$DTSI_FILE" ]; then
    # Remove duplicate /dts-v1/ from DTSI
    sed -i '/\/dts-v1\/;/d' "$DTSI_FILE"
    # Fix mt7981.dtsi include path for Kernel 6.6
    sed -i 's/#include "mt7981.dtsi"/#include <arm64\/mediatek\/mt7981.dtsi>/g' "$DTSI_FILE"
fi

# 2. Add Device definition to filogic.mk
# We inherit from cmcc_rax3000m which is very similar to XR30.
cat << 'EOF' >> target/linux/mediatek/image/filogic.mk

define Device/cmcc_xr30-emmc
  $(call Device/cmcc_rax3000m)
  DEVICE_MODEL := XR30 (eMMC)
  DEVICE_DTS := mt7981b-cmcc-xr30-emmc
  SUPPORTED_DEVICES := cmcc,xr30-emmc cmcc,rax3000m-emmc
  UBI_PART :=
  KERNEL_IN_UBI :=
  DEVICE_PACKAGES += arm-trusted-firmware-mediatek-mt7981-emmc-ddr4 uboot-mediatek-mt7981_cmcc_rax3000m-emmc
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
