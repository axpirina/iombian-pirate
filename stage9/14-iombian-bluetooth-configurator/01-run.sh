#!/bin/bash -e

PROJECT_NAME="iombian-bluetooth-configurator"
INSTALLATION_PATH="/opt/iombian-bluetooth-configurator"

# Create the installation folder
on_chroot << EOF
if [ -d "$INSTALLATION_PATH" ]; then
  rm -rf ${INSTALLATION_PATH}
fi
mkdir -p $INSTALLATION_PATH
EOF

install -m 644 -g root -o root ${PROJECT_NAME}/requirements.txt ${ROOTFS_DIR}$INSTALLATION_PATH
install -m 644 -g root -o root ${PROJECT_NAME}/systemd/${PROJECT_NAME}.service ${ROOTFS_DIR}/etc/systemd/system
cp -r ${PROJECT_NAME}/src/* ${ROOTFS_DIR}$INSTALLATION_PATH

# Create the virtual environment
on_chroot << EOF
cd $INSTALLATION_PATH
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install --no-cache-dir -r requirements.txt

# Patch pybleno for newer kernels / Python 3.11 (Debian 12).
# pybleno 0.11 has no newer release with these fixes, so they are applied here:
#  1. Python 3.11 removed the 'rU' file mode (ValueError: invalid mode: 'rU')
#  2. Newer kernels expect a 16-byte HCI filter (Errno 22 on setsockopt);
#     "<LLLHxx" pads the 14-byte structure with two bytes (Adam-Langley/pybleno#63)
PYBLENO_HCI=\$(find $INSTALLATION_PATH/venv/lib -path '*pybleno/hci_socket/BluetoothHCI/BluetoothHCI.py')
PYBLENO_SOCKET=\$(find $INSTALLATION_PATH/venv/lib -path '*pybleno/hci_socket/Hci.py')
sed -i "s/fdopen(self.__r, 'rU')/fdopen(self.__r, 'r')/" \$PYBLENO_HCI
sed -i 's/struct.pack("<LLLH", typeMask, eventMask1, eventMask2, opcode)/struct.pack("<LLLHxx", typeMask, eventMask1, eventMask2, opcode)/' \$PYBLENO_SOCKET
grep -q "fdopen(self.__r, 'r')" \$PYBLENO_HCI
grep -q '<LLLHxx' \$PYBLENO_SOCKET

chown -R $FIRST_USER_NAME:$FIRST_USER_NAME $INSTALLATION_PATH

systemctl enable ${PROJECT_NAME}
EOF