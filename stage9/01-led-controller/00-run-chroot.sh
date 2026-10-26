#!/bin/bash -e

# Bookworm-etik aurrera /boot/config.txt /boot/firmware/config.txt-ra mugitu da
CONFIG_FILE="/boot/config.txt"
if [ -f /boot/firmware/config.txt ]; then
  CONFIG_FILE="/boot/firmware/config.txt"
fi
CMDLINE_FILE="/boot/cmdline.txt"
if [ -f /boot/firmware/cmdline.txt ]; then
  CMDLINE_FILE="/boot/firmware/cmdline.txt"
fi

# enable power led (GPIO14)
echo "enable_uart=1" >> "$CONFIG_FILE"

# enable 64-bit kernel and userland (required for Node.js 22 / Node-RED 5.0)
echo "arm_64bit=1" >> "$CONFIG_FILE"
