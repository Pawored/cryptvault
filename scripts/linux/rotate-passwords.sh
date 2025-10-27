#!/bin/bash
# =============================================================================
# CryptVault - Password Rotation Script
# =============================================================================
#
# Rotates passwords by re-encrypting files with a new password
#
# Usage:
#   ./scripts/rotate-passwords.sh <directory> <old-password> <new-password>
#
# Examples:
#   ./scripts/rotate-passwords.sh sandbox OldPass2023! NewPass2024!
#   ./scripts/rotate-passwords.sh ~/encrypted-files OldPass! NewPass!
#
# ⚠️ WARNING: This will decrypt and re-encrypt all files
#
# =============================================================================

# Check arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <directory> <old-password> <new-password>"
    echo ""
    echo "Arguments:"
    echo "  directory     - Directory containing encrypted files"
    echo "  old-password  - Current password"
    echo "  new-password  - New password to use"
    echo ""
    echo "Examples:"
    echo "  $0 sandbox OldPass2023! NewPass2024!"
    echo "  $0 ~/encrypted-files OldPass! NewPass!"
    echo ""
    echo "⚠️ WARNING: This will decrypt and re-encrypt all files"
    echo "   Make sure you have backups before proceeding!"
    exit 1
fi

# Arguments
DIRECTORY="$1"
OLD_PASSWORD="$2"
NEW_PASSWORD="$3"

# Path to CryptVault
CRYPTVAULT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=============================================="
echo "CryptVault - Password Rotation"
echo "=============================================="
echo "Directory: $DIRECTORY"
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

# Warning
echo "⚠️ WARNING: Password Rotation Process"
echo ""
echo "This will:"
echo "  1. Decrypt all files with old password"
echo "  2. Re-encrypt with new password"
echo "  3. Replace old encrypted files"
echo ""
echo "Make sure you have backups before proceeding!"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted by user"
    exit 0
fi
echo ""

# Create temporary directory for rotation
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Using temporary directory: $TEMP_DIR"
echo ""

# Statistics
TOTAL_FILES=${#encrypted_files[@]}
SUCCESS_COUNT=0
FAIL_COUNT=0

# Process each file
for file in "${encrypted_files[@]}"; do
    filename=$(basename "$file")
    base_filename="${filename%.encrypted}"
    
    echo "Processing: $filename"
    
    # Step 1: Decrypt with old password
    echo "  1/3 Decrypting with old password..."
    if ! python "$CRYPTVAULT_PATH/src/file_encryption_sandbox.py" decrypt "$file" \
        -p "$OLD_PASSWORD" \
        -o "$TEMP_DIR/$base_filename" 2>/dev/null; then
        echo "  ❌ Failed to decrypt (wrong old password?)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi
    
    # Step 2: Re-encrypt with new password
    echo "  2/3 Re-encrypting with new password..."
    if ! python "$CRYPTVAULT_PATH/src/file_encryption_sandbox.py" encrypt "$TEMP_DIR/$base_filename" \
        -p "$NEW_PASSWORD" \
        -o "$TEMP_DIR/$base_filename.encrypted" 2>/dev/null; then
        echo "  ❌ Failed to re-encrypt"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        rm -f "$TEMP_DIR/$base_filename"
        continue
    fi
    
    # Step 3: Replace old encrypted file
    echo "  3/3 Replacing old encrypted file..."
    if mv "$TEMP_DIR/$base_filename.encrypted" "$file" 2>/dev/null; then
        echo "  ✅ Success - password rotated"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "  ❌ Failed to replace file"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    # Cleanup temp files
    rm -f "$TEMP_DIR/$base_filename"
    
    echo ""
done

# Summary
echo "=============================================="
echo "Password Rotation Summary"
echo "=============================================="
echo "Total files: $TOTAL_FILES"
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "✅ All passwords rotated successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Test decryption with new password"
    echo "  2. Update your password manager"
    echo "  3. Delete old backups (after verifying)"
    exit 0
else
    echo "⚠️ Some files failed password rotation"
    echo ""
    echo "Failed files still use old password."
    echo "Successfully rotated files use new password."
    echo ""
    echo "Recommendation: Review failed files and try again"
    exit 1
fi
