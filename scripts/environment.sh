#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
# Retry apt-get update to handle network issues
for i in {1..3}; do sudo apt-get update && break || sleep 5; done
sudo apt-get install -y --no-install-recommends \
    build-essential libncurses5-dev libncursesw5-dev \
    zlib1g-dev gawk git gettext libssl-dev xsltproc wget unzip python3 \
    python3-pip python3-pyelftools python3-setuptools libelf-dev binutils \
    bzip2 flex g++-multilib gcc-multilib libc6-dev-i386 patch qemu-utils \
    rsync device-tree-compiler ccache file cpio
