#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root so it can mount the image read-only." >&2
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <image.img|image.zip>" >&2
    exit 1
fi

input=$(realpath "$1")
workdir=$(mktemp -d)
loop_device=""

cleanup() {
    if mountpoint -q "$workdir/root/boot/firmware"; then
        umount "$workdir/root/boot/firmware"
    fi
    if mountpoint -q "$workdir/root"; then
        umount "$workdir/root"
    fi
    if [[ -n "$loop_device" ]]; then
        losetup -d "$loop_device"
    fi
    rm -rf "$workdir"
}
trap cleanup EXIT

case "$input" in
    *.zip)
        unzip -q "$input" -d "$workdir"
        mapfile -t images < <(find "$workdir" -maxdepth 1 -name '*.img' -print)
        if [[ ${#images[@]} -ne 1 ]]; then
            echo "Expected exactly one .img file in $input" >&2
            exit 1
        fi
        image=${images[0]}
        ;;
    *.img)
        image=$input
        ;;
    *)
        echo "Only .img and .zip files are supported." >&2
        exit 1
        ;;
esac

mkdir -p "$workdir/root/boot/firmware"
loop_device=$(losetup --show --find --partscan "$image")
mount -o ro "${loop_device}p2" "$workdir/root"
mount -o ro "${loop_device}p1" "$workdir/root/boot/firmware"

root=$workdir/root
boot=$root/boot/firmware

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

[[ -L $root/boot/config ]] || fail "The legacy /boot/config compatibility link is missing"
[[ $(readlink "$root/boot/config") == firmware/config ]] || fail "The legacy configuration link is incorrect"

[[ -L $root/etc/systemd/system/multi-user.target.wants/ssh.service ]] || fail "SSH is not enabled"
[[ -L $root/etc/systemd/system/multi-user.target.wants/wpa_supplicant.service ]] || fail "wpa_supplicant is not enabled"
[[ -L $root/etc/systemd/system/multi-user.target.wants/dhcpcd.service ]] || fail "dhcpcd is not enabled"
[[ -L $root/etc/systemd/system/sysinit.target.wants/confinit-boot@boot-firmware-config.service ]] || fail "Confinit boot configuration is not enabled"
[[ -L $root/etc/systemd/system/multi-user.target.wants/confinit-final@boot-firmware-config.service ]] || fail "Confinit final configuration is not enabled"

wetty_unit=$root/etc/systemd/system/wetty.service
grep -q -- '--host 0.0.0.0' "$wetty_unit" || fail "WeTTY is not accessible from the local network"
grep -q '^After=.*ssh.service' "$wetty_unit" || fail "WeTTY does not wait for SSH"
grep -q '^Wants=.*ssh.service' "$wetty_unit" || fail "WeTTY does not request SSH"

awk -F: '$1 == "iompi" { found=1; if ($3 != 0) exit 1 } END { if (!found) exit 1 }' \
    "$root/etc/shadow" || fail "The default password is not marked for rotation"

awk '/^sshd:/ { in_ssh=1 } in_ssh && /^  enabled: true$/ { enabled=1 } END { exit !enabled }' \
    "$boot/config/parameters.yml" || fail "Confinit would disable SSH"
grep -q 'mode: "0600"' "$boot/config/.confinit-boot.yml" || fail "Wi-Fi configuration permissions are not restricted"
grep -q 'len $value' "$boot/config/etc/wpa_supplicant/wpa_supplicant.conf.template" || fail "Hashed Wi-Fi PSKs are not supported"
[[ -x $boot/config/scripts/boot/00-enable-ssh.sh ]] || fail "SSH first-boot recovery is missing"
[[ -f $boot/config/scripts/boot/13-protect-secrets.py ]] || fail "Wi-Fi secret protection is missing"
[[ -f $boot/config/scripts/final/99-require-password-change.sh ]] || fail "Password rotation is missing"

echo "PASS: offline image checks completed successfully."
