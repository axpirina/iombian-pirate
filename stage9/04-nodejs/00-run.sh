#!/bin/bash -e

NODE_VERSION="22.21.1"
NODE_SHA256="e660365729b434af422bcd2e8e14228637ecf24a1de2cd7c916ad48f2a0521e1"
NODE_ARCHIVE="node-v${NODE_VERSION}-linux-arm64.tar.xz"

# Node-RED 5.0 requires Node.js >= 22. Install a pinned arm64 release
# instead of executing a mutable NodeSource setup script.
on_chroot << EOF
curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/${NODE_ARCHIVE}" -o "/tmp/${NODE_ARCHIVE}"
echo "${NODE_SHA256}  /tmp/${NODE_ARCHIVE}" | sha256sum -c -
tar -xJf "/tmp/${NODE_ARCHIVE}" -C /usr/local --strip-components=1
rm "/tmp/${NODE_ARCHIVE}"
node --version
EOF