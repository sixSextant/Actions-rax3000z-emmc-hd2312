#!/bin/bash

# 更改默认地址为192.168.6.1
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# 添加 kwrt 软件源 (用于编译时选择插件)
sed -i '$a src-git kwrt https://github.com/kiddin9/kwrt-packages' feeds.conf.default

# 配置插件库软件源 (用于固件运行时在线安装插件)
# 1. 禁用签名检查
sed -i 's/option check_signature/# option check_signature/g' package/base-files/files/etc/opkg.conf
# 2. 添加 binary repo
mkdir -p package/base-files/files/etc/opkg/
echo "src/gz openwrt_kiddin9 https://dl.openwrt.ai/latest/packages/aarch64_cortex-a53/kiddin9" >> package/base-files/files/etc/opkg/customfeeds.conf
