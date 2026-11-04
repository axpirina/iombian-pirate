#!/bin/bash -e

BORINGPROXY_VERSION="v0.10.0"
BORINGPROXY_BINARY_NAME="boringproxy"
INSTALLATION_FOLDER="/usr/local/bin"
BORINGPROXY_BINARY_PATH=${INSTALLATION_FOLDER}/${BORINGPROXY_BINARY_NAME}
BORINGPROXY_SHA256="5805e0f064ce3aa72e5a0b4dd00c0bf4150995cb1f1b7b80f2b3a78da78d1d27"

# Download and verify the pinned release.
curl -fsSL https://github.com/boringproxy/boringproxy/releases/download/${BORINGPROXY_VERSION}/boringproxy-linux-arm -o ${BORINGPROXY_BINARY_PATH}
echo "${BORINGPROXY_SHA256}  ${BORINGPROXY_BINARY_PATH}" | sha256sum -c -

# Set permissions
chmod +x ${BORINGPROXY_BINARY_PATH}