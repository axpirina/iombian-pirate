#!/bin/bash -e

./init-submodules.sh

echo "Modifying stage2"
mv stage2/EXPORT_IMAGE stage2/.EXPORT_IMAGE
[ -f stage2/EXPORT_NOOBS ] && mv stage2/EXPORT_NOOBS stage2/.EXPORT_NOOBS || true

echo "Building iombian image ..."
./build-docker.sh

echo "Restoring stage2"
mv stage2/.EXPORT_IMAGE stage2/EXPORT_IMAGE
[ -f stage2/.EXPORT_NOOBS ] && mv stage2/.EXPORT_NOOBS stage2/EXPORT_NOOBS || true