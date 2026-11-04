#!/bin/bash -e

VERSION="$(cat config/VERSION)"
ARCH="arm6"

BOOT_CONFIG_FOLDER=boot/firmware/config

# Copy configuration to Bookworm's firmware partition and overlay local hardening.
mkdir -p "${ROOTFS_DIR}/boot/firmware"
cp -av config "${ROOTFS_DIR}/boot/firmware"
cp -av config-overlay/. "${ROOTFS_DIR}/${BOOT_CONFIG_FOLDER}/"
ln -sfn firmware/config "${ROOTFS_DIR}/boot/config"
sed -i '/^sshd:/,/^$/ s/^  enabled: false$/  enabled: true/' "${ROOTFS_DIR}/${BOOT_CONFIG_FOLDER}/parameters.yml"
sed -i 's/mode: "0640"/mode: "0600"/' "${ROOTFS_DIR}/${BOOT_CONFIG_FOLDER}/.confinit-boot.yml"
sed -i 's@{{ else if eq $par "psk" -}}{{ $par }}="{{ $value -}}"@{{ else if eq $par "psk" -}}{{ if eq (len $value) 64 }}{{ $par }}={{ $value -}}{{ else }}{{ $par }}="{{ $value -}}"{{ end }}@g' "${ROOTFS_DIR}/${BOOT_CONFIG_FOLDER}/etc/wpa_supplicant/wpa_supplicant.conf.template"

# Install and enable confinit
on_chroot <<EOF
curl -fsSL https://github.com/jriguera/confinit/releases/download/v${VERSION}/confinit-${VERSION}-linux-${ARCH} -o /bin/confinit
echo "9416c890b73b329be7da1485b52b4c609d7103788c0e334801b7748cff32b119  /bin/confinit" | sha256sum -c -
chmod a+x /bin/confinit

# Bookworm NetworkManager erabiltzen du, eta ez du
# /etc/wpa_supplicant/wpa_supplicant.conf-eko sare konfigurazioa inportatzen.
# Instalatu dhcpcd, ez baitago Bookworm-eko oinarrizko irudian, eta gaitu
# wpa_supplicant eta dhcpcd NetworkManager-en ordez.
apt-get update
apt-get install -y dhcpcd5
systemctl disable NetworkManager.service NetworkManager-wait-online.service || true
systemctl enable wpa_supplicant.service dhcpcd.service
EOF

# systemd units
install -m 644 -g root -o root confinit/systemd/wpa_supplicant.service ${ROOTFS_DIR}/lib/systemd/system
install -m 644 -g root -o root confinit/systemd/confinit-boot@.service ${ROOTFS_DIR}/lib/systemd/system
install -m 644 -g root -o root confinit/systemd/confinit-intermediate@.service ${ROOTFS_DIR}/lib/systemd/system
install -m 644 -g root -o root confinit/systemd/confinit-final@.service ${ROOTFS_DIR}/lib/systemd/system

on_chroot <<EOF
# Enable service
mv "/lib/systemd/system/confinit-boot@.service" "/lib/systemd/system/confinit-boot@boot-firmware-config.service"
mv "/lib/systemd/system/confinit-intermediate@.service" "/lib/systemd/system/confinit-intermediate@boot-firmware-config.service"
mv "/lib/systemd/system/confinit-final@.service" "/lib/systemd/system/confinit-final@boot-firmware-config.service"
systemctl enable "confinit-boot@boot-firmware-config.service"
systemctl enable "confinit-intermediate@boot-firmware-config.service"
systemctl enable "confinit-final@boot-firmware-config.service"
mkdir -p /${BOOT_CONFIG_FOLDER}

# Keep SSH available from first boot and require rotation of the default password.
systemctl enable ssh.service
chage -d 0 "$FIRST_USER_NAME"
EOF
