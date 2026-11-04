#!/bin/bash -e

restore_stage2() {
    if [ -f stage2/.EXPORT_IMAGE ]; then
        mv stage2/.EXPORT_IMAGE stage2/EXPORT_IMAGE
    fi
    if [ -f stage2/.EXPORT_NOOBS ]; then
        mv stage2/.EXPORT_NOOBS stage2/EXPORT_NOOBS
    fi
}

trap restore_stage2 EXIT

./init-submodules.sh

echo "Modifying stage2"
mv stage2/EXPORT_IMAGE stage2/.EXPORT_IMAGE
[ -f stage2/EXPORT_NOOBS ] && mv stage2/EXPORT_NOOBS stage2/.EXPORT_NOOBS || true

echo "Building iombian image ..."
./build-docker.sh