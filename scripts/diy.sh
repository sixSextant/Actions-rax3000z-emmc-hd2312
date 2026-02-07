#!/bin/bash

# Add Kwrt packages feed
# We only add the feed here. The main workflow handles 'feeds update -a' and 'feeds install -a'.
echo "src-git kwrt_packages https://github.com/kiddin9/kwrt-packages" >> feeds.conf.default
