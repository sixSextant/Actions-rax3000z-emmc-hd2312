#!/bin/bash
set -ex
export DEBIAN_FRONTEND=noninteractive
# Retry apt-get update to handle network issues
for i in {1..3}; do sudo apt-get update && break || sleep 5; done
sudo apt-get install -y --no-install-recommends \
    bc \
    binutils \
    build-essential \
    bzip2 \
    ccache \
    cpio \
    device-tree-compiler \
    file \
    flex \
    g++-multilib \
    gawk \
    gcc-multilib \
    gengetopt \
    gettext \
    git \
    gperf \
    libc6-dev-i386 \
    libelf-dev \
    libncurses-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libssl-dev \
    libxml-parser-perl \
    patch \
    perl \
    python3 \
    python3-dev \
    python3-pip \
    python3-pyelftools \
    python3-setuptools \
    python3-yaml \
    qemu-utils \
    rsync \
    subversion \
    swig \
    time \
    unzip \
    wget \
    xsltproc \
    zlib1g-dev
