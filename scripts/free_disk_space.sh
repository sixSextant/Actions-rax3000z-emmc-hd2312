#!/usr/bin/env bash

echo "=============================================================================="
echo "Freeing up disk space on CI system"
echo "=============================================================================="

# When using easimon/maximize-build-space, manual cleanup of these large directories
# is usually already handled by the action. Redundant deletion might cause IO overhead.
# We keep this script for reference or if we switch back to standard runners without the action.

# sudo rm -rf /usr/share/dotnet
# sudo rm -rf /usr/local/lib/android
# sudo rm -rf /opt/ghc

df -hT
echo "=============================================================================="
