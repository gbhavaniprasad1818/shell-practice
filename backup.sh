#!/bin/bash

# The directory you want to back up.
SOURCE_DIR="$HOME/Documents"

# The directory where backup archieves will be stored.
BACKUP_DIR="mnt/backups/tar_archives"

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Get a timestamp for the filename (UTC time recommended by me)
TIMESTAMP=$(date +"%y-%m-%d_%H-%M-%S")

# Define the name of the backup file
BACKUP_FILE="backup_$TIMESTAMP.tar.gz"

# Create the compressed archive
echo "Starting tar backup of $SOURCE_DIR..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$SOURCE_DIR" . --warning=no-file-changed

# Check if the tar command was successful
if [ $? -eq 0 ]
then
	echo "Backup successful: $BACKUP_DIR/$BACKUP_FILE"
else
	echo "Backup Failed!"
	exit 1
fi
