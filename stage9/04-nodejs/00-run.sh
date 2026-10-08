#!/bin/bash -e

# Debian bullseye is armhf by default. Node-RED 5.0 requires Node.js >= 22,
# which is only available for arm64. Install a 64-bit kernel userland combo.
on_chroot << EOF
dpkg --add-architecture arm64
apt-get update
apt-get install -y libc6:arm64 libstdc++6:arm64
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs
EOF