#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly SOURCE_DIR="$HOME/services"
readonly BACKUP_DIR="/mnt/backup/backups"
readonly DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"

mkdir -p /mnt/backup

mount /dev/sda1 /mnt/backup/
mkdir -p "${BACKUP_DIR}"

rsync -av --delete \
  "${SOURCE_DIR}/" \
  --link-dest "${LATEST_LINK}" \
  "${BACKUP_PATH}"

rm -rf "${LATEST_LINK}"
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"

umount /mnt/backup
echo "done"

