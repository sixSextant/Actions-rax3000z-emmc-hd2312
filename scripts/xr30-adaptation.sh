#!/bin/bash
set -e

# This script integrates XR30 eMMC support using Kiddin9's device definitions
# which are more complete for Kernel 6.6.

# 1. Download DTS files from Kiddin9's Kwrt repository
# The image builder expects DTS files in target/linux/mediatek/dts/
DTS_DIR_IMAGE="target/linux/mediatek/dts"
# The kernel builder might also look in the overlay directory
if [ -d "target/linux/mediatek/files-6.6" ]; then
    DTS_DIR_KERNEL="target/linux/mediatek/files-6.6/arch/arm64/boot/dts/mediatek"
elif [ -d "target/linux/mediatek/files-6.1" ]; then
    DTS_DIR_KERNEL="target/linux/mediatek/files-6.1/arch/arm64/boot/dts/mediatek"
else
    DTS_DIR_KERNEL="target/linux/mediatek/files/arch/arm64/boot/dts/mediatek"
fi

mkdir -p ${DTS_DIR_IMAGE}
mkdir -p ${DTS_DIR_KERNEL}

KIDDIN9_DTS_URL="https://raw.githubusercontent.com/kiddin9/Kwrt/master/devices/mediatek_filogic/diy/target/linux/mediatek/dts"

# Function to download and patch
setup_dts() {
    local file=$1
    local dest_dir=$2
    local is_dtsi=$3

    wget -q "${KIDDIN9_DTS_URL}/${file}" -O "${dest_dir}/${file}"
    if [ ! -s "${dest_dir}/${file}" ]; then
        echo "Error: ${file} is empty or not found"
        return 1
    fi

    # Patch for Kernel 6.6 compatibility
    if [ "$is_dtsi" = "true" ]; then
        sed -i '/\/dts-v1\/;/d' "${dest_dir}/${file}"
        sed -i 's/#include "mt7981.dtsi"/#include <arm64\/mediatek\/mt7981.dtsi>/g' "${dest_dir}/${file}"
    fi
}

# Download and setup for both directories
setup_dts "mt7981b-cmcc-xr30-emmc.dts" "${DTS_DIR_IMAGE}" "false"
setup_dts "mt7981b-cmcc-xr30-emmc.dts" "${DTS_DIR_KERNEL}" "false"

# Handle DTSI (try both names)
if wget -q "${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30.dtsi" -O "${DTS_DIR_IMAGE}/mt7981b-cmcc-xr30.dtsi"; then
    setup_dts "mt7981b-cmcc-xr30.dtsi" "${DTS_DIR_IMAGE}" "true"
    cp "${DTS_DIR_IMAGE}/mt7981b-cmcc-xr30.dtsi" "${DTS_DIR_KERNEL}/mt7981b-cmcc-xr30.dtsi"
elif wget -q "${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dtsi" -O "${DTS_DIR_IMAGE}/mt7981b-cmcc-xr30-emmc.dtsi"; then
    setup_dts "mt7981b-cmcc-xr30-emmc.dtsi" "${DTS_DIR_IMAGE}" "true"
    cp "${DTS_DIR_IMAGE}/mt7981b-cmcc-xr30-emmc.dtsi" "${DTS_DIR_KERNEL}/mt7981b-cmcc-xr30-emmc.dtsi"
else
    echo "Error: Could not download DTSI file"
    exit 1
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
