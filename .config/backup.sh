#!/bin/bash

set -e

SOURCE_DIR="/home/me"
BACKUP_DIR="/mnt/backup"
DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"
BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
LATEST_LINK="${BACKUP_DIR}/latest"

echo "fetching luks key from stdin"
luks_pass=$(cat)

echo "decrypting backup disk"
echo -n "$luks_pass" | /usr/sbin/cryptsetup luksOpen /dev/sda1 backup -d -

echo "mounting backup disk"
mkdir -p "${BACKUP_DIR}"
mount /dev/mapper/backup ${BACKUP_DIR}

echo "syncing backups"
rsync --archive --delete \
  "${SOURCE_DIR}/" \
  --link-dest "${LATEST_LINK}" \
  "${BACKUP_PATH}"

rm -rf "${LATEST_LINK}"
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"

echo "unmounting & closing luks"
umount /mnt/backup
/usr/sbin/cryptsetup luksClose backup

echo "done"

