#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
# Retry apt-get update to handle network issues
for i in {1..3}; do sudo apt-get update && break || sleep 5; done
sudo apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bc \
    binutils \
    bison \
    build-essential \
    bzip2 \
    ccache \
    cmake \
    cpio \
    curl \
    device-tree-compiler \
    file \
    flex \
    g++-multilib \
    gawk \
    gcc-multilib \
    gengetopt \
    gettext \
    git \
    git-core \
    gperf \
    jq \
    libc6-dev-i386 \
    libelf-dev \
    libncurses-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libssl-dev \
    libtool \
    libxml-parser-perl \
    lzma \
    patch \
    perl \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python3-pyelftools \
    python3-setuptools \
    python3-yaml \
    qemu-utils \
    rsync \
    squashfs-tools \
    subversion \
    swig \
    time \
    unzip \
    wget \
    xsltproc \
    zlib1g-dev
