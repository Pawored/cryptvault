#!/bin/bash
# =============================================================================
# CryptVault - Decrypt All Script
# =============================================================================
#
# Decrypts all .encrypted files in a directory
#
# Usage:
#   ./scripts/decrypt-all.sh <directory> <password>
#   ./scripts/decrypt-all.sh <directory> -k <key-name> -p <password>
#
# Examples:
#   ./scripts/decrypt-all.sh sandbox MyPassword123!
#   ./scripts/decrypt-all.sh ~/encrypted-files MyPassword123!
#   ./scripts/decrypt-all.sh sandbox -k backup-key -p MyPassword123!
#
# ⚠️ WARNING: This will attempt to decrypt ALL .encrypted files
#
# =============================================================================

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <directory> <password>"
    echo "   or: $0 <directory> -k <key-name> -p <password>"
    echo ""
    echo "Examples:"
    echo "  $0 sandbox MyPassword123!"
    echo "  $0 ~/encrypted-files MyPassword123!"
    echo "  $0 sandbox -k backup-key -p MyPassword123!"
    echo ""
    echo "⚠️ WARNING: This will decrypt ALL .encrypted files in the directory"
    exit 1
fi

# Arguments
DIRECTORY="$1"
shift

# Parse remaining arguments for key-name or password
KEY_NAME=""
PASSWORD=""

if [ "$1" = "-k" ]; then
    KEY_NAME="$2"
    shift 2
    if [ "$1" = "-p" ]; then
        PASSWORD="$2"
        shift 2
    fi
else
    PASSWORD="$1"
fi

# Validate
if [ -z "$PASSWORD" ]; then
    echo "❌ Error: Password is required"
    exit 1
fi

# Path to CryptVault
CRYPTVAULT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=============================================="
echo "CryptVault - Decrypt All Files"
echo "=============================================="
echo "Directory: $DIRECTORY"
if [ -n "$KEY_NAME" ]; then
    echo "Using key: $KEY_NAME"
fi
echo "Date: $(date)"
echo ""

# Check if directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "❌ Error: Directory does not exist: $DIRECTORY"
    exit 1
fi

# Find encrypted files
mapfile -t encrypted_files < <(find "$DIRECTORY" -maxdepth 1 -type f -name "*.encrypted")

if [ ${#encrypted_files[@]} -eq 0 ]; then
    echo "⚠️ No .encrypted files found in $DIRECTORY"
    exit 0
fi

echo "Found ${#encrypted_files[@]} encrypted file(s)"
echo ""

# Confirmation prompt
echo "⚠️ WARNING: About to decrypt ${#encrypted_files[@]} file(s)"
echo ""
read -p "Continue? (y/N): " -n 1 -r
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

for file in "${encrypted_files[@]}"; do
    FILE_COUNT=$((FILE_COUNT + 1))
    filename=$(basename "$file")
    
    echo "[$FILE_COUNT/${#encrypted_files[@]}] Decrypting: $filename"
    
    # Build decrypt command
    DECRYPT_CMD=(
        python "$CRYPTVAULT_PATH/src/file_encryption_sandbox.py"
        decrypt "$file"
        -p "$PASSWORD"
    )
    
    # Add key-name if specified
    if [ -n "$KEY_NAME" ]; then
        DECRYPT_CMD+=(-n "$KEY_NAME")
    fi
    
    # Decrypt file
    if "${DECRYPT_CMD[@]}" 2>/dev/null; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo "    ✅ Success"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "    ❌ Failed"
    fi
done

echo ""
echo "=============================================="
echo "Decryption Summary"
echo "=============================================="
echo "Total files: $FILE_COUNT"
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "✅ All files decrypted successfully!"
    echo ""
    echo "Decrypted files saved with .decrypted extension"
    exit 0
else
    echo "⚠️ Some files failed to decrypt"
    echo ""
    echo "Possible reasons:"
    echo "  - Wrong password"
    echo "  - Wrong key name"
    echo "  - Corrupted encrypted file"
    echo "  - Files encrypted with different passwords"
    exit 1
fi
