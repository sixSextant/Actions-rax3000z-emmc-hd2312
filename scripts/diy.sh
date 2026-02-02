#!/bin/bash

#更改默认地址为192.168.6.1
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# 添加 kwrt 软件源
sed -i '$a src-git kwrt https://github.com/kiddin9/kwrt-packages' feeds.conf.default
