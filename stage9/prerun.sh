#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
	copy_previous
fi

# piwheels only provides armhf wheels; use PyPI for this arm64 image.
install -m 644 files/pip.conf "${ROOTFS_DIR}/etc/pip.conf"
install -m 644 files/pip-constraints.txt "${ROOTFS_DIR}/etc/iombian-pip-constraints.txt"
