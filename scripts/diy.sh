#!/bin/bash

# 更改默认地址为192.168.6.1
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# 已移除 Kwrt 插件库集成，仅保留基础配置
