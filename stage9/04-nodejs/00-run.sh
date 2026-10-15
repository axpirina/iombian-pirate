#!/bin/bash -e

# Bookworm-arm64 userland is native 64-bit: install Node.js 22 directly.
on_chroot << EOF
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs
EOF