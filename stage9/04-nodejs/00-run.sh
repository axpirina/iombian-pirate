#!/bin/bash -e

# Node-RED 5.0 requires Node.js >= 22. The base image is already arm64,
# so install Node.js directly from NodeSource without mixing Debian releases.
on_chroot << EOF
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs
EOF