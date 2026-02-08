#!/usr/bin/env bash

echo "=============================================================================="
echo "Aggressively freeing up disk space on CI system"
echo "=============================================================================="

df -h
echo "Removing large packages and tools..."
sudo apt-get purge -y \
  azure-cli \
  google-cloud-sdk \
  google-chrome-stable \
  firefox \
  powershell \
  mono-devel \
  libgl1-mesa-dri \
  microsoft-edge-stable \
  google-cloud-cli \
  dotnet-sdk-* \
  ghc-* \
  zulu-*

sudo apt-get autoremove -y
sudo apt-get clean

echo "Removing large directories..."
sudo rm -rf /usr/share/dotnet
sudo rm -rf /usr/local/lib/android
sudo rm -rf /opt/ghc
sudo rm -rf /usr/local/share/boost
sudo rm -rf /usr/local/.ghcup
sudo rm -rf /usr/share/swift
sudo rm -rf /usr/local/lib/node_modules

# Clean up Docker images
sudo docker image prune -a -f

df -h
echo "=============================================================================="
