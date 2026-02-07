#!/bin/bash

# This script integrates XR30 eMMC support using the user's provided DTS
# and augmenting it with necessary eMMC boot nodes for 24.10.

DTS_DIR="target/linux/mediatek/dts"
TARGET_DTS="${DTS_DIR}/mt7981b-cmcc-xr30-emmc.dts"

# 1. Use the user's provided DTS as the base
cp mt7981-cmcc-xr30-emmc.dtsi ${TARGET_DTS}

# 2. Add model and compatible identification (missing in the .dtsi)
sed -i '/\/ {/a \	model = "CMCC XR30 (eMMC version)";\n	compatible = "cmcc,xr30-emmc", "mediatek,mt7981";' ${TARGET_DTS}

# 3. Add the missing eMMC/MMC nodes required for 24.10 booting
cat << 'EOF' >> ${TARGET_DTS}

&mmc0 {
	bus-width = <8>;
	cap-mmc-highspeed;
	max-frequency = <26000000>;
	non-removable;
	pinctrl-names = "default", "state_uhs";
	pinctrl-0 = <&mmc0_pins_default>;
	pinctrl-1 = <&mmc0_pins_uhs>;
	vmmc-supply = <&reg_3p3v>;
	#address-cells = <1>;
	#size-cells = <0>;
	status = "okay";

	card@0 {
		compatible = "mmc-card";
		reg = <0>;

		block {
			compatible = "block-device";

			partitions {
				block-partition-factory {
					partname = "factory";

					nvmem-layout {
						compatible = "fixed-layout";
						#address-cells = <1>;
						#size-cells = <1>;

						eeprom_factory_0: eeprom@0 {
							reg = <0x0 0x1000>;
						};

						macaddr_factory_24: macaddr@24 {
							reg = <0x24 0x6>;
						};

						macaddr_factory_2a: macaddr@2a {
							reg = <0x2a 0x6>;
						};
					};
				};
			};
		};
	};
};

&pio {
	mmc0_pins_default: mmc0-pins {
		mux {
			function = "flash";
			groups = "emmc_45";
		};
	};

	mmc0_pins_uhs: mmc0-uhs-pins {
		mux {
			function = "flash";
			groups = "emmc_45";
		};
	};
};

&usb_phy {
	status = "okay";
};
EOF

# 4. Add the Device definition to filogic.mk
cat << 'EOF' >> target/linux/mediatek/image/filogic.mk

define Device/cmcc_xr30-emmc
  DEVICE_VENDOR := CMCC
  DEVICE_MODEL := XR30 (eMMC)
  DEVICE_DTS := mt7981b-cmcc-xr30-emmc
  SUPPORTED_DEVICES := cmcc,xr30-emmc cmcc,rax3000m-emmc
  DEVICE_PACKAGES := kmod-mt7981-firmware mt7981-wo-firmware kmod-usb3 automount f2fsck mkf2fs
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

# 5. Runtime identification
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/etc/board.d/02_network
sed -i '/cmcc,rax3000m|/a \	cmcc,xr30-emmc|' target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh
