#!/bin/bash
# =============================================================================
# CryptVault - Daily Backup Script
# =============================================================================
# 
# Automatically encrypts and backs up important files daily
#
# Usage:
#   ./scripts/daily-backup.sh
#
# Schedule with cron (daily at 2 AM):
#   crontab -e
#   0 2 * * * /path/to/cryptvault/scripts/daily-backup.sh
#
# =============================================================================

# -------------------------------
# CONFIGURATION - EDIT THESE
# -------------------------------

# Source directory to backup
BACKUP_DIR="$HOME/important-docs"

# Key name for encryption
KEY_NAME="daily-backup"

# Password for encryption (CHANGE THIS!)
PASSWORD="DailyBackup2024!"

# Destination for encrypted files
BACKUP_ROOT="/backup/encrypted"

# Date format for backup folders
DATE=$(date +%Y%m%d)

# Path to CryptVault
CRYPTVAULT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# -------------------------------
# SCRIPT START
# -------------------------------

echo "=========================================="
echo "CryptVault Daily Backup"
echo "Date: $(date)"
echo "=========================================="

# Create destination directory
DEST="$BACKUP_ROOT/$DATE"
mkdir -p "$DEST"

echo "Backup source: $BACKUP_DIR"
echo "Backup destination: $DEST"
echo ""

# Check if source directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Error: Source directory does not exist: $BACKUP_DIR"
    exit 1
fi

# Count files
FILE_COUNT=0
SUCCESS_COUNT=0
FAIL_COUNT=0

# Encrypt all files in backup directory
echo "Starting encryption..."
for file in "$BACKUP_DIR"/*; do
    if [ -f "$file" ]; then
        FILE_COUNT=$((FILE_COUNT + 1))
        filename=$(basename "$file")
        
        echo "[$FILE_COUNT] Encrypting: $filename"
        
        # Encrypt file
        if python "$CRYPTVAULT_PATH/src/file_encryption_sandbox.py" encrypt "$file" \
            -k "$KEY_NAME" -p "$PASSWORD" \
            -o "$DEST/$filename.enc" 2>/dev/null; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            echo "    ✅ Success"
        else
            FAIL_COUNT=$((FAIL_COUNT + 1))
            echo "    ❌ Failed"
        fi
    fi
done

echo ""
echo "=========================================="
echo "Backup Summary"
echo "=========================================="
echo "Total files: $FILE_COUNT"
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "Destination: $DEST"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "✅ Backup completed successfully!"
    exit 0
else
    echo "⚠️ Backup completed with errors"
    exit 1
fi
