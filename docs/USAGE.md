# 📖 Usage Guide

Complete reference for using CryptVault from the command line.

---

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Command Overview](#command-overview)
- [Encrypt Command](#encrypt-command)
- [Decrypt Command](#decrypt-command)
- [Key Management](#key-management)
- [Global Options](#global-options)
- [Common Workflows](#common-workflows)
- [Tips and Tricks](#tips-and-tricks)

---

## Quick Start

### Encrypt Your First File

```bash
# Create a test file
echo "My secret data" > secret.txt

# Encrypt it with a password
cryptvault encrypt secret.txt -p MyPassword123

# Check the result
ls sandbox/
# Output: secret.txt.encrypted, .keys.json
```

### Decrypt the File

```bash
# Decrypt using the same password
cryptvault decrypt sandbox/secret.txt.encrypted -p MyPassword123

# Check the decrypted file
cat sandbox/secret.txt.decrypted
# Output: My secret data
```

**That's it!** You've encrypted and decrypted your first file. 🎉

---

## Command Overview

CryptVault provides four main commands:

| Command | Description |
|---------|-------------|
| `encrypt` | Encrypt files |
| `decrypt` | Decrypt files |
| `save-key` | Save keys for reuse |
| `list-keys` | List saved keys |

### Basic Syntax

```bash
cryptvault [global-options] <command> [command-options]
```

### Get Help

```bash
# General help
cryptvault --help

# Help for specific command
cryptvault encrypt --help
cryptvault decrypt --help
```

---

## Encrypt Command

Encrypt files using passwords, random keys, or saved keys.

### Syntax

```bash
cryptvault encrypt <input-file> [options]
```

### Options

| Option | Short | Description |
|--------|-------|-------------|
| `--output PATH` | `-o` | Output file path |
| `--password TEXT` | `-p` | Password for encryption |
| `--key-name TEXT` | `-k` | Use a saved key |

### Method 1: Encrypt with Password

```bash
cryptvault encrypt document.pdf -p MySecurePassword123
```

**Output:**
```
✓ File encrypted: sandbox/document.pdf.encrypted
✓ Key saved as: key_2024-10-27T10:30:00
```

**What happens:**
- File is encrypted using your password
- Encrypted file saved to `sandbox/`
- Key is automatically saved with timestamp

### Method 2: Encrypt with Random Key

```bash
cryptvault encrypt confidential.docx
```

**Output:**
```
⚠ Randomly generated key: gAAAAABl8xKpQm5f...
✓ File encrypted: sandbox/confidential.docx.encrypted
✓ Key saved as: key_2024-10-27T10:31:00

⚠ IMPORTANT: Save this key! You'll need it to decrypt.
```

**What happens:**
- Generates a cryptographically secure random key
- Displays the key (SAVE IT!)
- Encrypts and saves the file

### Method 3: Encrypt with Saved Key

```bash
# First, save a key
cryptvault save-key project-alpha -p AlphaPass2024

# Then use it to encrypt
cryptvault encrypt report.xlsx -k project-alpha -p AlphaPass2024
```

**Output:**
```
✓ File encrypted: sandbox/report.xlsx.encrypted
✓ Using saved key: project-alpha
```

### Method 4: Custom Output Path

```bash
cryptvault encrypt data.csv \
  -o /backup/secure/data.csv.enc \
  -p BackupPassword2024
```

**Output:**
```
✓ File encrypted: /backup/secure/data.csv.enc
```

### Examples

```bash
# Encrypt a photo
cryptvault encrypt vacation.jpg -p Summer2024!

# Encrypt a database backup
cryptvault encrypt database_backup.sql -p DBPass_Secure_2024

# Encrypt with saved key
cryptvault encrypt taxes_2024.pdf -k financial-docs -p MyTaxPass

# Encrypt to specific location
cryptvault encrypt sensitive.txt -o ~/encrypted/sensitive.enc -p Pass123
```

---

## Decrypt Command

Decrypt previously encrypted files.

### Syntax

```bash
cryptvault decrypt <encrypted-file> [options]
```

### Options

| Option | Short | Description |
|--------|-------|-------------|
| `--output PATH` | `-o` | Output file path |
| `--password TEXT` | `-p` | Password for decryption |
| `--key TEXT` | `-k` | Direct key (base64) |
| `--key-name TEXT` | `-n` | Name of saved key |

### Method 1: Decrypt with Password

```bash
cryptvault decrypt sandbox/document.pdf.encrypted -p MySecurePassword123
```

**Output:**
```
✓ File decrypted: sandbox/document.pdf.decrypted
```

### Method 2: Decrypt with Random Key

```bash
cryptvault decrypt sandbox/confidential.docx.encrypted \
  -k "gAAAAABl8xKpQm5f..."
```

**Output:**
```
✓ File decrypted: sandbox/confidential.docx.decrypted
```

### Method 3: Decrypt with Saved Key

```bash
cryptvault decrypt sandbox/report.xlsx.encrypted \
  -n project-alpha -p AlphaPass2024
```

**Output:**
```
✓ Using saved key: project-alpha
✓ File decrypted: sandbox/report.xlsx.decrypted
```

### Method 4: Custom Output Path

```bash
cryptvault decrypt /backup/secure/data.csv.enc \
  -o ~/restored/data.csv \
  -p BackupPassword2024
```

**Output:**
```
✓ File decrypted: /home/user/restored/data.csv
```

### Examples

```bash
# Decrypt a photo
cryptvault decrypt sandbox/vacation.jpg.encrypted -p Summer2024!

# Decrypt database backup
cryptvault decrypt sandbox/database_backup.sql.encrypted -p DBPass_Secure_2024

# Decrypt with saved key name
cryptvault decrypt sandbox/taxes_2024.pdf.encrypted \
  -n financial-docs -p MyTaxPass

# Decrypt to specific location
cryptvault decrypt ~/encrypted/sensitive.enc \
  -o ~/Documents/sensitive.txt -p Pass123
```

---

## Key Management

### Save Keys

Save passwords or keys with descriptive names for easy reuse.

#### Save a Password

```bash
cryptvault save-key work-projects -p MyWorkPass2024!
```

**Output:**
```
✓ Key 'work-projects' saved successfully
```

#### Save a Random Key

```bash
cryptvault save-key backup-key \
  -k "gAAAAABl8xKpQm5f..."
```

**Output:**
```
✓ Key 'backup-key' saved successfully
```

### List Saved Keys

View all your saved keys and their metadata.

```bash
cryptvault list-keys
```

**Output:**
```
📋 Saved keys:
------------------------------------------------------------
  • work-projects
    Type: password
    Created: 2024-10-27T10:30:00
    Used for: 3 files

  • backup-key
    Type: key
    Created: 2024-10-27T11:45:00
    Used for: 1 file

  • financial-docs
    Type: password
    Created: 2024-10-27T09:15:00
    Used for: 5 files
------------------------------------------------------------
Total: 3 saved keys
```

### Key Storage

Keys are stored in `sandbox/.keys.json`:

```json
{
  "work-projects": {
    "type": "password",
    "salt": "...",
    "created": "2024-10-27T10:30:00",
    "files": ["document.pdf.encrypted", ...]
  }
}
```

**⚠️ IMPORTANT:** 
- Keep `.keys.json` secure
- Never share it publicly
- Make backups in safe locations
- Already in `.gitignore`

---

## Global Options

Options that work with any command.

### Custom Sandbox Directory

```bash
cryptvault --sandbox-dir /secure/vault encrypt file.txt -p pass
```

**Use case:** Organize different projects in different directories

**Example:**
```bash
# Personal files
cryptvault --sandbox-dir ~/personal-vault encrypt diary.txt -p pass

# Work files
cryptvault --sandbox-dir ~/work-vault encrypt report.docx -p pass

# Backups
cryptvault --sandbox-dir /backup/encrypted encrypt data.sql -p pass
```

---

## Common Workflows

### Workflow 1: Daily Document Protection

```bash
# Morning: Encrypt sensitive work documents
cryptvault save-key daily-work -p DailyPass2024!
cryptvault encrypt client-data.xlsx -k daily-work -p DailyPass2024!
cryptvault encrypt meeting-notes.docx -k daily-work -p DailyPass2024!

# Evening: Decrypt when needed
cryptvault decrypt sandbox/client-data.xlsx.encrypted \
  -n daily-work -p DailyPass2024!
```

### Workflow 2: Secure File Sharing

```bash
# Sender:
# 1. Encrypt file
cryptvault encrypt secret-project.zip

# Output shows key: gAAAAABl8xKpQm5f...

# 2. Send file via email/cloud
# 3. Send key via different channel (SMS, Signal, etc.)

# Receiver:
# 1. Download encrypted file
# 2. Receive key separately
# 3. Decrypt
cryptvault decrypt secret-project.zip.encrypted \
  -k "gAAAAABl8xKpQm5f..."
```

### Workflow 3: Backup to Cloud

```bash
# Create encrypted backups
cryptvault save-key cloud-backup -p CloudBackup2024!

# Encrypt important files
cryptvault encrypt ~/Documents/taxes.pdf -k cloud-backup -p CloudBackup2024!
cryptvault encrypt ~/Documents/contracts.zip -k cloud-backup -p CloudBackup2024!

# Upload encrypted files to Dropbox/Google Drive
cp sandbox/*.encrypted ~/Dropbox/Backups/

# To restore later:
cryptvault decrypt ~/Dropbox/Backups/taxes.pdf.encrypted \
  -n cloud-backup -p CloudBackup2024!
```

### Workflow 4: Project-Based Organization

```bash
# Project A
cryptvault --sandbox-dir ~/vaults/project-a \
  save-key proj-a -p ProjectA_Pass2024

cryptvault --sandbox-dir ~/vaults/project-a \
  encrypt design.psd -k proj-a -p ProjectA_Pass2024

# Project B
cryptvault --sandbox-dir ~/vaults/project-b \
  save-key proj-b -p ProjectB_Pass2024

cryptvault --sandbox-dir ~/vaults/project-b \
  encrypt code.zip -k proj-b -p ProjectB_Pass2024
```

---

## Tips and Tricks

### Tip 1: Use Strong Passwords

```bash
# ❌ BAD - Weak passwords
cryptvault encrypt file.txt -p "123456"
cryptvault encrypt file.txt -p "password"

# ✅ GOOD - Strong passwords
cryptvault encrypt file.txt -p "Tr0nc0!D3#Ar0bl3s_2024"
cryptvault encrypt file.txt -p "My$ecur3P@ssw0rd!2024"
```

**Password Requirements:**
- Minimum 16 characters
- Mix of uppercase, lowercase, numbers, symbols
- No dictionary words
- Unique per project

### Tip 2: Always Backup Keys

```bash
# Backup .keys.json file
cp sandbox/.keys.json ~/safe-backup/.keys.json.backup

# Or encrypt the keys file itself
cryptvault encrypt sandbox/.keys.json -p MasterPassword2024!
```

### Tip 3: Use Aliases (Linux/Mac)

Add to `~/.bashrc` or `~/.zshrc`:

```bash
alias cve="python ~/cryptvault/src/file_encryption_sandbox.py encrypt"
alias cvd="python ~/cryptvault/src/file_encryption_sandbox.py decrypt"
alias cvl="python ~/cryptvault/src/file_encryption_sandbox.py list-keys"
```

**Usage:**
```bash
cve myfile.txt -p pass
cvd sandbox/myfile.txt.encrypted -p pass
cvl
```

### Tip 4: Batch Operations with Scripts

Create a bash script for batch encryption:

```bash
#!/bin/bash
# encrypt-all.sh

PASSWORD="MyBatchPassword2024!"

for file in ~/Documents/*.pdf; do
    cryptvault encrypt "$file" -p "$PASSWORD"
done

echo "✅ All PDFs encrypted"
```

### Tip 5: Verify Before Deleting Originals

```bash
# 1. Encrypt
cryptvault encrypt important.doc -p pass

# 2. Test decryption
cryptvault decrypt sandbox/important.doc.encrypted -p pass

# 3. Verify content matches
diff important.doc sandbox/important.doc.decrypted

# 4. Only if diff shows no differences, delete original
rm important.doc
```

### Tip 6: Use Descriptive Key Names

```bash
# ❌ BAD - Generic names
cryptvault save-key key1 -p pass
cryptvault save-key mykey -p pass

# ✅ GOOD - Descriptive names
cryptvault save-key tax-documents-2024 -p pass
cryptvault save-key client-abc-contracts -p pass
cryptvault save-key personal-photos-backup -p pass
```

### Tip 7: Organize by Sandbox Directories

```bash
# Create organized structure
mkdir -p ~/vaults/{personal,work,backup}

# Use different sandboxes
cryptvault --sandbox-dir ~/vaults/personal encrypt diary.txt -p pass
cryptvault --sandbox-dir ~/vaults/work encrypt report.docx -p pass
cryptvault --sandbox-dir ~/vaults/backup encrypt data.db -p pass
```

### Tip 8: Document Your Keys

Keep a physical note (in a safe place) with key names and hints:

```
Key Name: tax-documents-2024
Hint: [Your personal hint here]
Created: Oct 2024
Used for: Tax returns, receipts

Key Name: client-contracts
Hint: [Your hint]
Created: Oct 2024
Used for: All client legal documents
```

---

## Command Reference Quick Sheet

```bash
# ENCRYPT
cryptvault encrypt <file> -p <password>
cryptvault encrypt <file>  # Random key
cryptvault encrypt <file> -k <key-name> -p <password>
cryptvault encrypt <file> -o <output> -p <password>

# DECRYPT
cryptvault decrypt <file> -p <password>
cryptvault decrypt <file> -k <base64-key>
cryptvault decrypt <file> -n <key-name> -p <password>
cryptvault decrypt <file> -o <output> -p <password>

# KEY MANAGEMENT
cryptvault save-key <name> -p <password>
cryptvault save-key <name> -k <base64-key>
cryptvault list-keys

# GLOBAL OPTIONS
cryptvault --sandbox-dir <path> <command>
cryptvault --help
cryptvault <command> --help
```

---

## Next Steps

Now that you know how to use CryptVault:

1. **[See Examples](EXAMPLES.md)** - Real-world use cases
2. **[Read Security Guide](SECURITY.md)** - Best practices
3. **[Check FAQ](FAQ.md)** - Common questions
4. **[API Reference](API_REFERENCE.md)** - Use as a library

---

## Need Help?

- **Troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Issues:** [GitHub Issues](https://github.com/pawored/cryptvault/issues)
- **Email:** zogoxi-gobo52@protonmail.com

---

<div align="center">

[← Installation](INSTALLATION.md) • [Examples →](EXAMPLES.md)

</div>
