#!/bin/sh

set -e

for backend_server in $BACKEND_SERVERS; do
    echo "Sending a backup warning to $backend_server..."
    echo "say §4§lZa 5 minut nastąpi wyłączenie serwera w celu wykonania kopii zapasowej." | timeout -s KILL 1s docker compose attach $backend_server || [ $? -eq 137 ]
done

echo "Waiting 5 minutes..."
sleep 5m

echo "Stopping services for a backup..."
for service in $SERVICES; do
    docker compose stop $service
done

echo "Cleaning up old backups before creating a new one..."
OLD_BACKUPS=$(ls -1t /archive/backup_*.tar.zst 2>/dev/null | tail -n +4)
if [ -n "$OLD_BACKUPS" ]; then
    for old_backup in $OLD_BACKUPS; do
        echo "Removing an old backup: $old_backup"
        rm -f "$old_backup"
    done
    echo "Cleanup completed."
else
    echo "No old backups to remove."
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="backup_${TIMESTAMP}.tar.zst"

echo "Creating a backup: ${BACKUP_NAME}"
tar --zstd -cf "/archive/${BACKUP_NAME}" -C / backup

echo "Starting services after a backup..."
for service in $SERVICES; do
    docker compose start $service
done

echo "A backup created successfully: ${BACKUP_NAME}"

du -h "/archive/${BACKUP_NAME}"
