#!/bin/bash

# Add Kwrt packages feed
# We only add the feed here. The main workflow handles 'feeds update -a' and 'feeds install -a'.
echo "src-git kwrt_packages https://github.com/kiddin9/kwrt-packages" >> feeds.conf.default

# 更改默认地址为192.168.6.1
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate
