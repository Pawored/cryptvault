# 🎯 Examples

Real-world examples and use cases for CryptVault.

---

## 📋 Table of Contents

- [Basic Examples](#basic-examples)
- [Personal Use Cases](#personal-use-cases)
- [Professional Use Cases](#professional-use-cases)
- [Advanced Scenarios](#advanced-scenarios)
- [Automation Scripts](#automation-scripts)

---

## Basic Examples

### Example 1: Encrypt a Single File

**Scenario:** You have a sensitive document that needs protection.

```bash
# Encrypt
python src/file_encryption_sandbox.py encrypt passport_scan.pdf -p MySecurePass2024!

# Output:
# ✓ File encrypted: sandbox/passport_scan.pdf.encrypted
# ✓ Key saved as: key_2024-10-27T10:30:00
```

**Result:** 
- Original: `passport_scan.pdf` (keep or delete)
- Encrypted: `sandbox/passport_scan.pdf.encrypted` (safe to share/store)

### Example 2: Decrypt a File

**Scenario:** You need to access your encrypted document.

```bash
# Decrypt
python src/file_encryption_sandbox.py decrypt sandbox/passport_scan.pdf.encrypted -p MySecurePass2024!

# Output:
# ✓ File decrypted: sandbox/passport_scan.pdf.decrypted
```

**Result:**
- Decrypted file: `sandbox/passport_scan.pdf.decrypted`
- Rename or move as needed

### Example 3: Use Random Key

**Scenario:** Maximum security with randomly generated key.

```bash
# Encrypt with random key
python src/file_encryption_sandbox.py encrypt top_secret.docx

# Output:
# ⚠ Randomly generated key: gAAAAABl8xKpQm5fYT9L8w...
# ✓ File encrypted: sandbox/top_secret.docx.encrypted
# 
# ⚠ IMPORTANT: Save this key! You'll need it to decrypt.

# Save the key somewhere safe!

# Decrypt later
python src/file_encryption_sandbox.py decrypt sandbox/top_secret.docx.encrypted \
  -k "gAAAAABl8xKpQm5fYT9L8w..."
```

---

## Personal Use Cases

### Case 1: Protect Personal Documents

**Scenario:** Encrypt important personal documents before storing in the cloud.

```bash
# Step 1: Create a key for personal documents
python src/file_encryption_sandbox.py save-key personal-docs -p MyPersonalPass2024!

# Step 2: Encrypt all important documents
python src/file_encryption_sandbox.py encrypt ~/Documents/birth_certificate.pdf \
  -k personal-docs -p MyPersonalPass2024!

python src/file_encryption_sandbox.py encrypt ~/Documents/social_security.pdf \
  -k personal-docs -p MyPersonalPass2024!

python src/file_encryption_sandbox.py encrypt ~/Documents/marriage_certificate.pdf \
  -k personal-docs -p MyPersonalPass2024!

python src/file_encryption_sandbox.py encrypt ~/Documents/will.pdf \
  -k personal-docs -p MyPersonalPass2024!

# Step 3: Upload encrypted files to cloud
cp sandbox/*.encrypted ~/Dropbox/Important/

# Step 4: Delete originals (after verifying encryption worked)
# Only do this after testing decryption!
```

**When you need them:**
```bash
python src/file_encryption_sandbox.py decrypt ~/Dropbox/Important/birth_certificate.pdf.encrypted \
  -n personal-docs -p MyPersonalPass2024!
```

### Case 2: Secure Photo Backup

**Scenario:** Backup private photos securely.

```bash
# Create key for photos
python src/file_encryption_sandbox.py save-key private-photos -p PhotoPass2024!

# Encrypt photo albums
python src/file_encryption_sandbox.py encrypt ~/Pictures/private/vacation.zip \
  -k private-photos -p PhotoPass2024!

python src/file_encryption_sandbox.py encrypt ~/Pictures/private/family.zip \
  -k private-photos -p PhotoPass2024!

# Move to external drive or cloud
mv sandbox/*.encrypted /media/backup/encrypted-photos/
```

### Case 3: Password Manager Backup

**Scenario:** Encrypt your password manager database backup.

```bash
# Daily backup
python src/file_encryption_sandbox.py save-key password-backup -p SecureBackupPass2024!

python src/file_encryption_sandbox.py encrypt ~/.password-store/passwords.kdbx \
  -k password-backup -p SecureBackupPass2024! \
  -o ~/Backups/passwords-$(date +%Y%m%d).kdbx.enc

# Upload to cloud
rclone copy ~/Backups/passwords-*.enc remote:backups/
```

### Case 4: Medical Records

**Scenario:** Encrypt and organize medical records.

```bash
# Create key for medical records
python src/file_encryption_sandbox.py save-key medical-records -p MedicalPass2024!

# Encrypt records by year
python src/file_encryption_sandbox.py --sandbox-dir ~/health-vault/2024 \
  encrypt ~/Documents/medical/lab-results-2024.pdf \
  -k medical-records -p MedicalPass2024!

python src/file_encryption_sandbox.py --sandbox-dir ~/health-vault/2024 \
  encrypt ~/Documents/medical/prescriptions-2024.pdf \
  -k medical-records -p MedicalPass2024!
```

---

## Professional Use Cases

### Case 5: Client Data Protection

**Scenario:** Protect client data for different projects.

```bash
# Client A
python src/file_encryption_sandbox.py save-key client-alpha -p AlphaClient2024!
python src/file_encryption_sandbox.py encrypt client-alpha-proposal.docx \
  -k client-alpha -p AlphaClient2024!
python src/file_encryption_sandbox.py encrypt client-alpha-contract.pdf \
  -k client-alpha -p AlphaClient2024!

# Client B
python src/file_encryption_sandbox.py save-key client-beta -p BetaClient2024!
python src/file_encryption_sandbox.py encrypt client-beta-proposal.docx \
  -k client-beta -p BetaClient2024!
python src/file_encryption_sandbox.py encrypt client-beta-contract.pdf \
  -k client-beta -p BetaClient2024!

# List all keys to see organization
python src/file_encryption_sandbox.py list-keys
```

### Case 6: Financial Data

**Scenario:** Protect tax returns and financial documents.

```bash
# Create key for financial year
python src/file_encryption_sandbox.py save-key tax-2024 -p TaxDocuments2024!

# Encrypt all tax-related files
python src/file_encryption_sandbox.py encrypt ~/Documents/Taxes/2024/w2.pdf \
  -k tax-2024 -p TaxDocuments2024!

python src/file_encryption_sandbox.py encrypt ~/Documents/Taxes/2024/1099.pdf \
  -k tax-2024 -p TaxDocuments2024!

python src/file_encryption_sandbox.py encrypt ~/Documents/Taxes/2024/receipts.zip \
  -k tax-2024 -p TaxDocuments2024!

python src/file_encryption_sandbox.py encrypt ~/Documents/Taxes/2024/return.pdf \
  -k tax-2024 -p TaxDocuments2024!

# Backup to secure location
cp sandbox/*.encrypted /secure-backup/taxes/2024/
```

### Case 7: Code Repository Secrets

**Scenario:** Encrypt sensitive configuration files before committing.

```bash
# Create key for project
python src/file_encryption_sandbox.py save-key project-secrets -p ProjectSecrets2024!

# Encrypt sensitive files
python src/file_encryption_sandbox.py encrypt .env \
  -k project-secrets -p ProjectSecrets2024! \
  -o .env.encrypted

python src/file_encryption_sandbox.py encrypt config/secrets.yaml \
  -k project-secrets -p ProjectSecrets2024! \
  -o config/secrets.yaml.encrypted

# Add to git
git add .env.encrypted config/secrets.yaml.encrypted

# Add originals to .gitignore
echo ".env" >> .gitignore
echo "config/secrets.yaml" >> .gitignore

# Team members can decrypt with shared password
python src/file_encryption_sandbox.py decrypt .env.encrypted \
  -n project-secrets -p ProjectSecrets2024! \
  -o .env
```

### Case 8: Database Backups

**Scenario:** Encrypt database dumps before storing.

```bash
# Create backup key
python src/file_encryption_sandbox.py save-key db-backup -p DBBackup2024!

# Create and encrypt backup
pg_dump mydb > backup.sql
python src/file_encryption_sandbox.py encrypt backup.sql \
  -k db-backup -p DBBackup2024! \
  -o /backups/db-backup-$(date +%Y%m%d).sql.enc

# Remove unencrypted backup
rm backup.sql

# Upload to cloud
aws s3 cp /backups/db-backup-*.enc s3://my-backups/database/
```

---

## Advanced Scenarios

### Case 9: Secure File Sharing

**Scenario:** Share a file securely with someone.

**Sender:**
```bash
# Method 1: Using password
python src/file_encryption_sandbox.py encrypt confidential-report.pdf -p SharedPassword2024!

# Send file via email/cloud: confidential-report.pdf.encrypted
# Send password via different channel (SMS, Signal, phone call)

# Method 2: Using random key (more secure)
python src/file_encryption_sandbox.py encrypt confidential-report.pdf

# Output shows: gAAAAABl8xKpQm5fYT9L8w...
# Send file via email/cloud
# Send key via different secure channel
```

**Receiver:**
```bash
# Method 1: With password
python src/file_encryption_sandbox.py decrypt confidential-report.pdf.encrypted -p SharedPassword2024!

# Method 2: With key
python src/file_encryption_sandbox.py decrypt confidential-report.pdf.encrypted \
  -k "gAAAAABl8xKpQm5fYT9L8w..."
```

### Case 10: Multi-Layer Encryption

**Scenario:** Extra security by encrypting twice.

```bash
# First encryption with password
python src/file_encryption_sandbox.py encrypt ultra-secret.txt -p FirstPassword2024!

# Second encryption with random key
python src/file_encryption_sandbox.py encrypt sandbox/ultra-secret.txt.encrypted

# Output: gAAAAABl8xKpQm5fYT9L8w...
# Now you need BOTH password AND key to decrypt

# To decrypt (reverse order):
# 1. Decrypt with key
python src/file_encryption_sandbox.py decrypt sandbox/ultra-secret.txt.encrypted.encrypted \
  -k "gAAAAABl8xKpQm5fYT9L8w..."

# 2. Decrypt with password
python src/file_encryption_sandbox.py decrypt sandbox/ultra-secret.txt.encrypted.decrypted \
  -p FirstPassword2024!
```

### Case 11: Rotating Passwords

**Scenario:** Change encryption password periodically.

```bash
# Current setup (old password)
python src/file_encryption_sandbox.py save-key archive-old -p OldPassword2023

# Encrypt files
python src/file_encryption_sandbox.py encrypt important.pdf -k archive-old -p OldPassword2023

# Time to rotate (new password)
# 1. Decrypt with old password
python src/file_encryption_sandbox.py decrypt sandbox/important.pdf.encrypted \
  -n archive-old -p OldPassword2023

# 2. Create new key
python src/file_encryption_sandbox.py save-key archive-new -p NewPassword2024!

# 3. Re-encrypt with new password
python src/file_encryption_sandbox.py encrypt sandbox/important.pdf.decrypted \
  -k archive-new -p NewPassword2024!

# 4. Delete old encrypted file
rm sandbox/important.pdf.encrypted

# 5. Rename new encrypted file
mv sandbox/important.pdf.decrypted.encrypted sandbox/important.pdf.encrypted
```

### Case 12: Travel Security

**Scenario:** Encrypt sensitive files before traveling.

```bash
# Before travel: Encrypt sensitive files
python src/file_encryption_sandbox.py save-key travel-2024 -p TravelSafe2024!

python src/file_encryption_sandbox.py encrypt ~/Documents/passport.pdf \
  -k travel-2024 -p TravelSafe2024!

python src/file_encryption_sandbox.py encrypt ~/Documents/visa.pdf \
  -k travel-2024 -p TravelSafe2024!

python src/file_encryption_sandbox.py encrypt ~/Documents/insurance.pdf \
  -k travel-2024 -p TravelSafe2024!

# Upload to cloud (only encrypted files)
cp sandbox/*.encrypted ~/Dropbox/Travel/

# Delete originals from laptop
rm ~/Documents/passport.pdf ~/Documents/visa.pdf ~/Documents/insurance.pdf

# During travel: Access if needed
python src/file_encryption_sandbox.py decrypt ~/Dropbox/Travel/passport.pdf.encrypted \
  -n travel-2024 -p TravelSafe2024!
```

---

## Automation Scripts

### Script 1: Daily Backup

**File:** `daily-backup.sh`

```bash
#!/bin/bash
# Daily encrypted backup script

# Configuration
BACKUP_DIR="$HOME/important-docs"
KEY_NAME="daily-backup"
PASSWORD="DailyBackup2024!"
DATE=$(date +%Y%m%d)
DEST="/backup/encrypted/$DATE"

# Create destination
mkdir -p "$DEST"

# Encrypt all files in backup directory
for file in "$BACKUP_DIR"/*; do
    if [ -f "$file" ]; then
        echo "Encrypting: $(basename "$file")"
        python src/file_encryption_sandbox.py encrypt "$file" \
            -k "$KEY_NAME" -p "$PASSWORD" \
            -o "$DEST/$(basename "$file").enc"
    fi
done

echo "✅ Backup complete: $DEST"

# Optional: Upload to cloud
# rclone copy "$DEST" remote:backups/$DATE/
```

**Usage:**
```bash
chmod +x daily-backup.sh
./daily-backup.sh

# Add to cron for automation
crontab -e
# Add: 0 2 * * * /path/to/daily-backup.sh
```

### Script 2: Batch Encrypt by Extension

**File:** `encrypt-by-type.sh`

```bash
#!/bin/bash
# Encrypt all files of specific type

EXTENSION="$1"  # e.g., pdf, docx, jpg
PASSWORD="$2"
DIRECTORY="${3:-.}"  # Default to current directory

if [ -z "$EXTENSION" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <extension> <password> [directory]"
    echo "Example: $0 pdf MyPass123 ~/Documents"
    exit 1
fi

echo "Encrypting all .$EXTENSION files in $DIRECTORY"

find "$DIRECTORY" -type f -name "*.$EXTENSION" | while read file; do
    echo "Processing: $file"
    python src/file_encryption_sandbox.py encrypt "$file" -p "$PASSWORD"
done

echo "✅ All .$EXTENSION files encrypted"
```

**Usage:**
```bash
chmod +x encrypt-by-type.sh
./encrypt-by-type.sh pdf MyPassword123! ~/Documents
./encrypt-by-type.sh docx MyPassword123! ~/Work
```

### Script 3: Verify Encryption

**File:** `verify-encryption.py`

```python
#!/usr/bin/env python3
"""Verify that encrypted files can be decrypted correctly"""

import sys
import subprocess
from pathlib import Path

def verify_file(encrypted_file, password):
    """Verify a file can be decrypted"""
    print(f"Verifying: {encrypted_file}")
    
    # Try to decrypt
    result = subprocess.run([
        "python", "src/file_encryption_sandbox.py",
        "decrypt", str(encrypted_file),
        "-p", password,
        "-o", "/tmp/verify-test"
    ], capture_output=True, text=True)
    
    # Check result
    if result.returncode == 0:
        print(f"✅ {encrypted_file} - OK")
        Path("/tmp/verify-test").unlink(missing_ok=True)
        return True
    else:
        print(f"❌ {encrypted_file} - FAILED")
        print(f"   Error: {result.stderr}")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: verify-encryption.py <password> [directory]")
        sys.exit(1)
    
    password = sys.argv[1]
    directory = sys.argv[2] if len(sys.argv) > 2 else "sandbox"
    
    # Find all encrypted files
    encrypted_files = Path(directory).glob("*.encrypted")
    
    # Verify each
    total = 0
    passed = 0
    
    for file in encrypted_files:
        total += 1
        if verify_file(file, password):
            passed += 1
    
    print(f"\n📊 Results: {passed}/{total} files verified")
    
    if passed == total:
        print("✅ All files can be decrypted")
        sys.exit(0)
    else:
        print("❌ Some files failed verification")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

**Usage:**
```bash
chmod +x verify-encryption.py
python verify-encryption.py MyPassword123!
python verify-encryption.py MyPassword123! ~/encrypted-backup
```

### Script 4: Organized Backup System

**File:** `organized-backup.sh`

```bash
#!/bin/bash
# Create organized encrypted backups by category

# Configuration
BACKUP_ROOT="/backup/encrypted"
PASSWORD="OrganizedBackup2024!"
DATE=$(date +%Y-%m-%d)

# Categories
declare -A CATEGORIES=(
    ["documents"]="$HOME/Documents/*.{pdf,docx,xlsx}"
    ["photos"]="$HOME/Pictures/*.{jpg,png,raw}"
    ["code"]="$HOME/Projects/*/.git"
    ["configs"]="$HOME/.config/*.conf"
)

# Create backup structure
for category in "${!CATEGORIES[@]}"; do
    DEST="$BACKUP_ROOT/$category/$DATE"
    mkdir -p "$DEST"
    
    echo "Backing up: $category"
    
    # Encrypt files in category
    for file in ${CATEGORIES[$category]}; do
        if [ -f "$file" ]; then
            echo "  - $(basename "$file")"
            python src/file_encryption_sandbox.py encrypt "$file" \
                -p "$PASSWORD" \
                -o "$DEST/$(basename "$file").enc"
        fi
    done
done

echo "✅ Organized backup complete: $BACKUP_ROOT"
```

**Usage:**
```bash
chmod +x organized-backup.sh
./organized-backup.sh

# Schedule monthly
crontab -e
# Add: 0 3 1 * * /path/to/organized-backup.sh
```

---

## Best Practices from Examples

### ✅ DO:
1. **Use strong, unique passwords** for different purposes
2. **Save keys with descriptive names** (e.g., `tax-2024`, `client-alpha`)
3. **Test decryption** before deleting originals
4. **Backup .keys.json** file securely
5. **Use different passwords** for different security levels
6. **Organize by project/category** using sandboxes
7. **Automate repetitive tasks** with scripts
8. **Verify backups** regularly

### ❌ DON'T:
1. **Don't use the same password** for everything
2. **Don't share keys and files** through the same channel
3. **Don't delete originals** before testing decryption
4. **Don't store .keys.json** in public places
5. **Don't use weak passwords** like "password123"
6. **Don't forget to backup** your keys
7. **Don't encrypt without testing** first
8. **Don't trust encryption alone** - use good security practices

---

## Next Steps

Want to learn more?

- **[API Reference](API_REFERENCE.md)** - Use CryptVault in your Python code
- **[Security Guide](SECURITY.md)** - Security best practices
- **[FAQ](FAQ.md)** - Common questions
- **[Troubleshooting](TROUBLESHOOTING.md)** - Fix common issues

---

<div align="center">

[← Usage Guide](USAGE.md) • [API Reference →](API_REFERENCE.md)

</div>
