#!/bin/bash
set -euo pipefail

# === CONFIGURABLE VARIABLES ===
MOUNT_POINT="/mnt/usb"
TARGET_NAME="boot.bit"

# === ENVIRONMENT VALIDATION ===
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "  sudo $0"
    exit 1
fi

if [ -z "${BITSTREAM:-}" ]; then
    echo "Environment variable BITSTREAM not set."
    exit 1
fi

if [ ! -f "$BITSTREAM" ]; then
    echo "Bitstream file '$BITSTREAM' not found."
    exit 1
fi

# === DETECT LATEST USB DEVICE ===
USB_DEV=$(lsblk -o NAME,TRAN,TYPE -n | \
    awk '$2 == "usb" && $3 == "disk" { print "/dev/" $1 }' | \
    xargs -I{} stat -c "%Y {}" {} 2>/dev/null | \
    sort -nr | head -n1 | cut -d' ' -f2)

if [ -z "$USB_DEV" ]; then
    echo "No USB device detected."
    exit 1
fi

echo "Detected USB device: $USB_DEV"

# === UNMOUNT IF ALREADY MOUNTED ===
if mount | grep -q "$USB_DEV"; then
    echo "Device is already mounted. Unmounting..."
    umount "$USB_DEV" || {
        echo "Failed to unmount $USB_DEV"
        exit 1
    }
fi

# === CONFIRM BEFORE FORMATTING ===
read -p "Are you sure you want to format $USB_DEV as FAT32? This will erase all data. (yes/[no]): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted by user."
    exit 0
fi

# === FORMAT DEVICE ===
echo "Formatting $USB_DEV as FAT32..."
mkfs.vfat -F 32 "$USB_DEV" || {
    echo "Failed to format $USB_DEV"
    exit 1
}

# === MOUNT DEVICE ===
echo "Mounting $USB_DEV to $MOUNT_POINT..."
mkdir -p "$MOUNT_POINT"
mount "$USB_DEV" "$MOUNT_POINT" || {
    echo "Failed to mount $USB_DEV"
    exit 1
}

# === COPY FILE ===
echo "Copying '$BITSTREAM' to '$MOUNT_POINT/$TARGET_NAME'..."
cp "$BITSTREAM" "$MOUNT_POINT/$TARGET_NAME" || {
    echo "Failed to copy bitstream."
    umount "$MOUNT_POINT"
    exit 1
}
sync

# === UNMOUNT ===
echo "Unmounting $MOUNT_POINT..."
umount "$MOUNT_POINT" || {
    echo "Failed to unmount $MOUNT_POINT"
    exit 1
}

echo "Done successfully."
