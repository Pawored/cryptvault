#!/bin/bash
# =============================================================================
# CryptVault - Sandbox Cleanup Script
# =============================================================================
#
# Cleans up old encrypted/decrypted files from sandbox
#
# Usage:
#   ./scripts/cleanup-sandbox.sh [days] [--dry-run]
#
# Examples:
#   ./scripts/cleanup-sandbox.sh             # Delete files older than 30 days
#   ./scripts/cleanup-sandbox.sh 7           # Delete files older than 7 days
#   ./scripts/cleanup-sandbox.sh 30 --dry-run  # Show what would be deleted
#
# =============================================================================

# Configuration
DAYS="${1:-30}"  # Default: 30 days
DRY_RUN=false

# Check for dry-run flag
if [ "$2" = "--dry-run" ] || [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
    if [ "$1" = "--dry-run" ]; then
        DAYS=30
    fi
fi

# Path to CryptVault
CRYPTVAULT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SANDBOX_DIR="$CRYPTVAULT_PATH/sandbox"

echo "=============================================="
echo "CryptVault - Sandbox Cleanup"
echo "=============================================="
echo "Sandbox: $SANDBOX_DIR"
echo "Delete files older than: $DAYS days"
if [ "$DRY_RUN" = true ]; then
    echo "Mode: DRY RUN (no files will be deleted)"
else
    echo "Mode: LIVE (files will be permanently deleted)"
fi
echo "Date: $(date)"
echo ""

# Check if sandbox exists
if [ ! -d "$SANDBOX_DIR" ]; then
    echo "❌ Error: Sandbox directory does not exist: $SANDBOX_DIR"
    exit 1
fi

# Find old files
echo "Searching for files older than $DAYS days..."
echo ""

# Find encrypted files
mapfile -t old_encrypted < <(find "$SANDBOX_DIR" -maxdepth 1 -name "*.encrypted" -mtime +$DAYS)

# Find decrypted files
mapfile -t old_decrypted < <(find "$SANDBOX_DIR" -maxdepth 1 -name "*.decrypted" -mtime +$DAYS)

# Combine arrays
old_files=("${old_encrypted[@]}" "${old_decrypted[@]}")

if [ ${#old_files[@]} -eq 0 ]; then
    echo "✅ No files older than $DAYS days found"
    exit 0
fi

echo "Found ${#old_files[@]} file(s) to delete:"
echo ""

# List files to be deleted
TOTAL_SIZE=0
for file in "${old_files[@]}"; do
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    TOTAL_SIZE=$((TOTAL_SIZE + size))
    size_human=$(numfmt --to=iec --suffix=B $size 2>/dev/null || echo "$size bytes")
    modified=$(stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || date -r "$file" +%Y-%m-%d 2>/dev/null)
    
    echo "  📄 $(basename "$file")"
    echo "     Size: $size_human | Modified: $modified"
done

echo ""
echo "Total size to free: $(numfmt --to=iec --suffix=B $TOTAL_SIZE 2>/dev/null || echo "$TOTAL_SIZE bytes")"
echo ""

# Dry run - exit here
if [ "$DRY_RUN" = true ]; then
    echo "🔍 DRY RUN - No files were deleted"
    echo ""
    echo "To actually delete these files, run without --dry-run:"
    echo "  $0 $DAYS"
    exit 0
fi

# Confirmation
echo "⚠️ WARNING: These files will be permanently deleted!"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted by user"
    exit 0
fi
echo ""

# Delete files
DELETED_COUNT=0
FAILED_COUNT=0

echo "Deleting files..."
for file in "${old_files[@]}"; do
    filename=$(basename "$file")
    if rm "$file" 2>/dev/null; then
        DELETED_COUNT=$((DELETED_COUNT + 1))
        echo "  ✅ Deleted: $filename"
    else
        FAILED_COUNT=$((FAILED_COUNT + 1))
        echo "  ❌ Failed: $filename"
    fi
done

echo ""
echo "=============================================="
echo "Cleanup Summary"
echo "=============================================="
echo "Files deleted: $DELETED_COUNT"
echo "Failed: $FAILED_COUNT"
echo "Space freed: $(numfmt --to=iec --suffix=B $TOTAL_SIZE 2>/dev/null || echo "$TOTAL_SIZE bytes")"
echo ""

if [ $FAILED_COUNT -eq 0 ]; then
    echo "✅ Cleanup completed successfully!"
    exit 0
else
    echo "⚠️ Cleanup completed with errors"
    exit 1
fi
