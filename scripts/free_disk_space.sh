#!/usr/bin/env bash

echo "=============================================================================="
echo "Freeing up disk space on CI system"
echo "=============================================================================="

df -h
echo "Removing large directories..."
# These are standard safe directories to remove on GitHub runners to free space
sudo rm -rf /usr/share/dotnet
sudo rm -rf /usr/local/lib/android
sudo rm -rf /opt/ghc
sudo rm -rf /usr/local/share/boost
sudo rm -rf /usr/local/.ghcup
sudo rm -rf /usr/share/swift
sudo rm -rf /usr/local/lib/node_modules

# Clean up Docker images
sudo docker image prune -a -f

# Aggressive apt cleanup
sudo apt-get clean

df -h
echo "=============================================================================="
