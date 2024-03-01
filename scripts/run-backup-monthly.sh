#!/usr/bin/env bash
# Backup daily with 365 days rotation

RESULT_FILE="$DAILY_BACKUP_DIR/$MYSQL_DATABASE-$(date +%Y%m%d%H%M%S).sql"

if mysqldump --single-transaction --set-gtid-purged=OFF --skip-add-drop-table --no-tablespaces --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" --result-file="$RESULT_FILE" "${MYSQL_DATABASE}" && gzip "$RESULT_FILE" > "$RESULT_FILE.gz"; then
    echo "$MYSQL_DATABASE dump was successful."
else
    echo "$MYSQL_DATABASE dump failed."
    exit 1
fi

find "$DAILY_BACKUP_DIR" -type f -name '*.sql' -mtime +365 -exec rm {} \;

if rclone copy "$RESULT_FILE.gz" "s3:$RCLONE_S3_BUCKET/"; then
    echo "$RESULT_FILE.gz successfully copied to remote location."
else
    echo "Failed to copy $RESULT_FILE.gz to remote location."
    exit 1
fi
