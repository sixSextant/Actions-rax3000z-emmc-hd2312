#!/bin/bash

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

wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30-emmc.dts -O ${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts || echo "Failed to download xr30-emmc.dts"
wget -q ${KIDDIN9_DTS_URL}/mt7981b-cmcc-xr30.dtsi -O ${DTS_DIR}/mt7981b-cmcc-xr30.dtsi || echo "Failed to download xr30.dtsi"

if [ ! -s "${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts" ]; then
    echo "Warning: mt7981b-cmcc-xr30-emmc.dts is empty or not found"
fi

# Patch DTS/DTSI for compatibility
# Remove duplicate /dts-v1/ from DTSI
sed -i '/\/dts-v1\/;/d' ${DTS_DIR}/mt7981b-cmcc-xr30.dtsi
# Fix mt7981.dtsi include path for Kernel 6.6
sed -i 's/#include "mt7981.dtsi"/#include <arm64\/mediatek\/mt7981.dtsi>/g' ${DTS_DIR}/mt7981b-cmcc-xr30.dtsi

# 2. Add Device definition to filogic.mk
# We inherit from cmcc_rax3000m which is very similar to XR30.
# We also include the ATF/U-Boot packages in DEVICE_PACKAGES to ensure they are built.
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
