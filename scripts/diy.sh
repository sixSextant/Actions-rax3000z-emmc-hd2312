#!/bin/bash

# Add Kwrt packages feed
echo "src-git kwrt_packages https://github.com/kiddin9/kwrt-packages" >> feeds.conf.default

# Update and install feeds
./scripts/feeds update -a
./scripts/feeds install -a
