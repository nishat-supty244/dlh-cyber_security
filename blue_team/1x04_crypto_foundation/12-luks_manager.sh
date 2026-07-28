#!/bin/bash
set -e

IMG="encrypted_volume.img"
VOL="secure_vol"
MNT="/mnt/secure_backup"

case "$1" in
    create)
        dd if=/dev/zero of="$IMG" bs=1M count=500 status=progress
        sudo cryptsetup luksFormat --batch-mode "$IMG"
        sudo cryptsetup luksOpen "$IMG" "$VOL"
        sudo mkfs.ext4 "/dev/mapper/$VOL"
        sudo cryptsetup luksClose "$VOL"
        echo "[+] Volume created successfully."
        ;;
    open)
        sudo cryptsetup luksOpen "$IMG" "$VOL"
        sudo mkdir -p "$MNT"
        sudo mount "/dev/mapper/$VOL" "$MNT"
        echo "[+] Volume opened and mounted at $MNT."
        ;;
    close)
        sudo umount "$MNT"
        sudo cryptsetup luksClose "$VOL"
        echo "[+] Volume closed."
        ;;
    *)
        echo "Usage: $0 {create|open|close}"
        exit 1
        ;;
esac
