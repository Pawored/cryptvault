#!/bin/bash
# =============================================================================
# CryptVault - Batch Decrypt Script
# =============================================================================
#
# Selectively decrypt multiple files with pattern matching
#
# Usage:
#   ./scripts/batch-decrypt.sh <directory> <pattern> <password>
#
# Examples:
#   ./scripts/batch-decrypt.sh sandbox "*.pdf.encrypted" MyPass123!
#   ./scripts/batch-decrypt.sh ~/backup "photo*.encrypted" PhotoPass!
#   ./scripts/batch-decrypt.sh sandbox "2024*.encrypted" BackupPass!
#
# =============================================================================

# Check arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <directory> <pattern> <password>"
    echo ""
    echo "Arguments:"
    echo "  directory  - Directory containing encrypted files"
    echo "  pattern    - Pattern to match (use quotes!)"
    echo "  password   - Password for decryption"
    echo ""
    echo "Examples:"
    echo "  $0 sandbox '*.pdf.encrypted' MyPass123!"
    echo "  $0 ~/backup 'photo*.encrypted' PhotoPass!"
    echo "  $0 sandbox '2024*.encrypted' BackupPass!"
    echo ""
    echo "Pattern Examples:"
    echo "  '*.pdf.encrypted'       - All PDF files"
    echo "  'photo*.encrypted'      - Files starting with 'photo'"
    echo "  '*2024*.encrypted'      - Files containing '2024'"
    echo "  'client-*.encrypted'    - Files starting with 'client-'"
    exit 1
fi

# Arguments
DIRECTORY="$1"
PATTERN="$2"
PASSWORD="$3"

# Path to CryptVault
CRYPTVAULT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=============================================="
echo "CryptVault - Batch Decrypt"
echo "=============================================="
echo "Directory: $DIRECTORY"
echo "Pattern: $PATTERN"
echo "Date: $(date)"
echo ""

# Check if directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "❌ Error: Directory does not exist: $DIRECTORY"
    exit 1
fi

# Find matching files
mapfile -t matched_files < <(find "$DIRECTORY" -maxdepth 1 -type f -name "$PATTERN")

if [ ${#matched_files[@]} -eq 0 ]; then
    echo "⚠️ No files matching pattern '$PATTERN' found in $DIRECTORY"
    exit 0
fi

echo "Found ${#matched_files[@]} file(s) matching pattern"
echo ""

# Show matched files
echo "Files to decrypt:"
for file in "${matched_files[@]}"; do
    echo "  📄 $(basename "$file")"
done
echo ""

# Confirmation
read -p "Decrypt these ${#matched_files[@]} file(s)? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted by user"
    exit 0
fi
echo ""

# Decrypt files
FILE_COUNT=0
SUCCESS_COUNT=0
FAIL_COUNT=0

for file in "${matched_files[@]}"; do
    FILE_COUNT=$((FILE_COUNT + 1))
    filename=$(basename "$file")
    
    echo "[$FILE_COUNT/${#matched_files[@]}] Decrypting: $filename"
    
    # Decrypt file
    if python "$CRYPTVAULT_PATH/src/file_encryption_sandbox.py" decrypt "$file" \
        -p "$PASSWORD" 2>/dev/null; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo "    ✅ Success"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "    ❌ Failed"
    fi
done

echo ""
echo "=============================================="
echo "Batch Decryption Summary"
echo "=============================================="
echo "Matched files: $FILE_COUNT"
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "✅ All matched files decrypted successfully!"
    exit 0
else
    echo "⚠️ Some files failed to decrypt"
    echo ""
    echo "Possible reasons:"
    echo "  - Wrong password"
    echo "  - Corrupted encrypted file"
    echo "  - Different passwords used for different files"
    exit 1
fi
