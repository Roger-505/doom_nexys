#!/bin/bash
set -euo pipefail

# === Get the latest ttyUSB device from dmesg ===
# LAST_TTY=$(dmesg | grep -oP 'ttyUSB\d+' | tail -1 || true)
LAST_TTY=ttyUSB1

if [ -z "$LAST_TTY" ]; then
    echo "No ttyUSB device found in dmesg."
    exit 1
fi

DEVICE="/dev/$LAST_TTY"

# === Check if the device actually exists ===
if [ ! -e "$DEVICE" ]; then
    echo "Device $DEVICE does not exist."
    exit 1
fi

echo "Opening minicom on $DEVICE..."
sudo minicom -D "$DEVICE" -b 115200 -8 -o
