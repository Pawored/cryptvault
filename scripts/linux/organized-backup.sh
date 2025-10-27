#!/bin/bash
# =============================================================================
# CryptVault - Organized Backup Script
# =============================================================================
#
# Creates organized encrypted backups by category
#
# Usage:
#   ./scripts/organized-backup.sh
#
# Schedule monthly (1st of month at 3 AM):
#   crontab -e
#   0 3 1 * * /path/to/cryptvault/scripts/organized-backup.sh
#
# =============================================================================

# -------------------------------
# CONFIGURATION - EDIT THESE
# -------------------------------

# Root directory for backups
BACKUP_ROOT="/backup/encrypted"

# Password for encryption (CHANGE THIS!)
PASSWORD="OrganizedBackup2024!"

# Date format
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Path to CryptVault
CRYPTVAULT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# -------------------------------
# CATEGORIES - CUSTOMIZE THESE
# -------------------------------

# Define backup categories and their source patterns
# Format: "category_name:source_pattern"
CATEGORIES=(
    "documents:$HOME/Documents/*.{pdf,docx,xlsx,txt}"
    "photos:$HOME/Pictures/*.{jpg,jpeg,png,raw,heic}"
    "videos:$HOME/Videos/*.{mp4,mov,avi,mkv}"
    "code:$HOME/Projects/**/*.{py,js,java,cpp,zip}"
    "configs:$HOME/.config/*.{conf,cfg,json,yaml,yml}"
    "databases:$HOME/Databases/*.{db,sql,sqlite}"
)

# -------------------------------
# SCRIPT START
# -------------------------------

echo "=============================================="
echo "CryptVault - Organized Backup"
echo "Date: $(date)"
echo "=============================================="
echo ""

# Statistics
TOTAL_CATEGORIES=0
TOTAL_FILES=0
TOTAL_SUCCESS=0
TOTAL_FAILED=0

# Process each category
for category_config in "${CATEGORIES[@]}"; do
    # Parse category configuration
    IFS=':' read -r category pattern <<< "$category_config"
    
    TOTAL_CATEGORIES=$((TOTAL_CATEGORIES + 1))
    
    echo "=========================================="
    echo "Category: $category"
    echo "=========================================="
    
    # Create category directory
    CATEGORY_DIR="$BACKUP_ROOT/$category/$DATE"
    mkdir -p "$CATEGORY_DIR"
    
    echo "Destination: $CATEGORY_DIR"
    echo "Pattern: $pattern"
    echo ""
    
    # Count files in this category
    CATEGORY_FILES=0
    CATEGORY_SUCCESS=0
    CATEGORY_FAILED=0
    
    # Expand pattern and encrypt files
    shopt -s nullglob globstar
    for file in $pattern; do
        if [ -f "$file" ]; then
            CATEGORY_FILES=$((CATEGORY_FILES + 1))
            TOTAL_FILES=$((TOTAL_FILES + 1))
            
            filename=$(basename "$file")
            echo "[$CATEGORY_FILES] Encrypting: $filename"
            
            # Encrypt file
            if python "$CRYPTVAULT_PATH/src/file_encryption_sandbox.py" encrypt "$file" \
                -p "$PASSWORD" \
                -o "$CATEGORY_DIR/$filename.enc" 2>/dev/null; then
                CATEGORY_SUCCESS=$((CATEGORY_SUCCESS + 1))
                TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
                echo "    ✅ Success"
            else
                CATEGORY_FAILED=$((CATEGORY_FAILED + 1))
                TOTAL_FAILED=$((TOTAL_FAILED + 1))
                echo "    ❌ Failed"
            fi
        fi
    done
    shopt -u nullglob globstar
    
    # Category summary
    echo ""
    echo "Category Summary:"
    echo "  Files: $CATEGORY_FILES"
    echo "  Success: $CATEGORY_SUCCESS"
    echo "  Failed: $CATEGORY_FAILED"
    echo ""
    
    if [ $CATEGORY_FILES -eq 0 ]; then
        echo "  ⚠️ No files found for pattern: $pattern"
    elif [ $CATEGORY_FAILED -eq 0 ]; then
        echo "  ✅ All files encrypted successfully"
    else
        echo "  ⚠️ Some files failed"
    fi
    echo ""
done

# Overall summary
echo "=============================================="
echo "Overall Backup Summary"
echo "=============================================="
echo "Categories processed: $TOTAL_CATEGORIES"
echo "Total files: $TOTAL_FILES"
echo "Successful: $TOTAL_SUCCESS"
echo "Failed: $TOTAL_FAILED"
echo "Backup location: $BACKUP_ROOT"
echo ""

# Create backup log
LOG_FILE="$BACKUP_ROOT/backup-log-$TIMESTAMP.txt"
{
    echo "CryptVault Organized Backup Log"
    echo "Date: $(date)"
    echo ""
    echo "Categories: $TOTAL_CATEGORIES"
    echo "Files: $TOTAL_FILES"
    echo "Success: $TOTAL_SUCCESS"
    echo "Failed: $TOTAL_FAILED"
} > "$LOG_FILE"

echo "Log saved: $LOG_FILE"
echo ""

# Exit status
if [ $TOTAL_FAILED -eq 0 ]; then
    echo "✅ Organized backup completed successfully!"
    exit 0
else
    echo "⚠️ Backup completed with $TOTAL_FAILED error(s)"
    exit 1
fi
