#!/usr/bin/env bash

echo "=============================================================================="
echo "Freeing up disk space on CI system"
echo "=============================================================================="

# Standard cleanup for GitHub runners
sudo rm -rf /usr/share/dotnet
sudo rm -rf /usr/local/lib/android
sudo rm -rf /opt/ghc

df -h
echo "=============================================================================="
