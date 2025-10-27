#!/bin/bash
# =============================================================================
# CryptVault - Encrypt by File Type
# =============================================================================
#
# Encrypts all files of a specific type in a directory
#
# Usage:
#   ./scripts/encrypt-by-type.sh <extension> <password> [directory]
#
# Examples:
#   ./scripts/encrypt-by-type.sh pdf MyPassword123! ~/Documents
#   ./scripts/encrypt-by-type.sh jpg PhotoPass2024! ~/Pictures
#   ./scripts/encrypt-by-type.sh docx WorkPass! ~/Work
#
# =============================================================================

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <extension> <password> [directory]"
    echo ""
    echo "Arguments:"
    echo "  extension  - File extension to encrypt (e.g., pdf, jpg, docx)"
    echo "  password   - Password for encryption"
    echo "  directory  - Directory to search (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $0 pdf MyPassword123! ~/Documents"
    echo "  $0 jpg PhotoPass2024! ~/Pictures"
    exit 1
fi

# Arguments
EXTENSION="$1"
PASSWORD="$2"
DIRECTORY="${3:-.}"

# Path to CryptVault
CRYPTVAULT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=========================================="
echo "CryptVault - Encrypt by Type"
echo "=========================================="
echo "Extension: .$EXTENSION"
echo "Directory: $DIRECTORY"
echo "Date: $(date)"
echo ""

# Check if directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "❌ Error: Directory does not exist: $DIRECTORY"
    exit 1
fi

# Find and encrypt files
FILE_COUNT=0
SUCCESS_COUNT=0
FAIL_COUNT=0

echo "Searching for *.$EXTENSION files..."
echo ""

while IFS= read -r -d '' file; do
    FILE_COUNT=$((FILE_COUNT + 1))
    filename=$(basename "$file")
    
    echo "[$FILE_COUNT] Encrypting: $filename"
    
    # Encrypt file
    if python "$CRYPTVAULT_PATH/src/file_encryption_sandbox.py" encrypt "$file" \
        -p "$PASSWORD" 2>/dev/null; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo "    ✅ Success"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "    ❌ Failed"
    fi
    
done < <(find "$DIRECTORY" -type f -name "*.$EXTENSION" -print0)

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Files found: $FILE_COUNT"
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ $FILE_COUNT -eq 0 ]; then
    echo "⚠️ No .$EXTENSION files found in $DIRECTORY"
    exit 0
elif [ $FAIL_COUNT -eq 0 ]; then
    echo "✅ All .$EXTENSION files encrypted successfully!"
    exit 0
else
    echo "⚠️ Some files failed to encrypt"
    exit 1
fi
