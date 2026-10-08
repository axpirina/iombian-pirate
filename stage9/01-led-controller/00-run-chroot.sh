#!/bin/bash -e

# enable power led (GPIO14)
echo "enable_uart=1" >> /boot/config.txt

# enable 64-bit kernel and userland (required for Node.js 22 / Node-RED 5.0)
echo "arm_64bit=1" >> /boot/config.txt
