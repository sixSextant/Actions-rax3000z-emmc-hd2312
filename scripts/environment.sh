#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    build-essential libncurses5-dev libncursesw5-dev \
    zlib1g-dev gawk git gettext libssl-dev xsltproc wget unzip python3 \
    python3-pip python3-pyelftools python3-setuptools libelf-dev binutils \
    bzip2 flex g++-multilib gcc-multilib libc6-dev-i386 patch qemu-utils \
    rsync device-tree-compiler
