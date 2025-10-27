# 🐧 Linux/Mac Scripts

Bash automation scripts for CryptVault on Linux and macOS.

---

## 📋 Available Scripts

| Script | Description | Difficulty |
|--------|-------------|------------|
| [daily-backup.sh](#daily-backupsh) | Automated daily backup | ⭐ Easy |
| [encrypt-by-type.sh](#encrypt-by-typesh) | Encrypt by file extension | ⭐ Easy |
| [organized-backup.sh](#organized-backupsh) | Organized category backups | ⭐⭐ Medium |
| [decrypt-all.sh](#decrypt-allsh) | Decrypt all files | ⭐ Easy |
| [batch-decrypt.sh](#batch-decryptsh) | Selective batch decryption | ⭐⭐ Medium |
| [cleanup-sandbox.sh](#cleanup-sandboxsh) | Clean old files | ⭐ Easy |
| [rotate-passwords.sh](#rotate-passwordssh) | Rotate passwords | ⭐⭐⭐ Advanced |

---

## 🚀 Quick Start

### Make Scripts Executable

```bash
# Navigate to scripts directory
cd scripts/linux

# Make all scripts executable
chmod +x *.sh

# Or make individual script executable
chmod +x daily-backup.sh
```

### Run a Script

```bash
# From project root
./scripts/linux/daily-backup.sh

# Or from scripts/linux directory
cd scripts/linux
./daily-backup.sh
```

---

## 📚 Script Documentation

### daily-backup.sh

**Purpose:** Automatically encrypt and backup files daily.

**Configuration:**
```bash
# Edit these variables in the script
BACKUP_DIR="$HOME/important-docs"  # Source directory
KEY_NAME="daily-backup"             # Key name
PASSWORD="DailyBackup2024!"         # Password (CHANGE THIS!)
BACKUP_ROOT="/backup/encrypted"     # Destination
```

**Usage:**
```bash
# Run manually
./scripts/linux/daily-backup.sh

# Schedule with cron (daily at 2 AM)
crontab -e
# Add: 0 2 * * * /path/to/cryptvault/scripts/linux/daily-backup.sh
```

**What it does:**
1. Scans source directory for files
2. Encrypts each file with specified password
3. Saves encrypted files to dated backup folder
4. Shows summary of successful/failed encryptions

**Example output:**
```
==========================================
CryptVault Daily Backup
==========================================
Backup source: /home/user/important-docs
Backup destination: /backup/encrypted/20241027

Starting encryption...
[1] Encrypting: document.pdf
    ✅ Success
[2] Encrypting: spreadsheet.xlsx
    ✅ Success

==========================================
Backup Summary
==========================================
Total files: 2
Successful: 2
Failed: 0
✅ Backup completed successfully!
```

---

### encrypt-by-type.sh

**Purpose:** Encrypt all files of a specific type in a directory.

**Usage:**
```bash
./scripts/linux/encrypt-by-type.sh <extension> <password> [directory]
```

**Examples:**
```bash
# Encrypt all PDFs in Documents
./scripts/linux/encrypt-by-type.sh pdf MyPassword123! ~/Documents

# Encrypt all JPGs in Pictures
./scripts/linux/encrypt-by-type.sh jpg PhotoPass2024! ~/Pictures

# Encrypt all DOCX files in current directory
./scripts/linux/encrypt-by-type.sh docx WorkPass! .
```

**What it does:**
1. Recursively searches for files with specified extension
2. Encrypts each file found
3. Saves to sandbox directory
4. Reports success/failure for each file

**Use cases:**
- Encrypt all photos before uploading to cloud
- Secure all PDFs in a project folder
- Backup all documents of specific type

---

### organized-backup.sh

**Purpose:** Create organized backups by category (documents, photos, videos, etc.).

**Configuration:**
```bash
# Edit categories in the script
declare -A CATEGORIES=(
    ["documents"]="$HOME/Documents/*.{pdf,docx,xlsx}"
    ["photos"]="$HOME/Pictures/*.{jpg,png}"
    ["videos"]="$HOME/Videos/*.{mp4,mov}"
    ["code"]="$HOME/Projects/*.zip"
)
```

**Usage:**
```bash
# Run manually
./scripts/linux/organized-backup.sh

# Schedule monthly (1st at 3 AM)
crontab -e
# Add: 0 3 1 * * /path/to/cryptvault/scripts/linux/organized-backup.sh
```

**Directory structure created:**
```
/backup/encrypted/
├── documents/
│   └── 2024-10-27/
│       ├── file1.pdf.enc
│       └── file2.docx.enc
├── photos/
│   └── 2024-10-27/
│       └── photo1.jpg.enc
└── videos/
    └── 2024-10-27/
        └── video1.mp4.enc
```

**What it does:**
1. Processes each category separately
2. Finds files matching patterns
3. Encrypts files with same password
4. Organizes in dated category folders
5. Creates backup log

---

### decrypt-all.sh

**Purpose:** Decrypt all .encrypted files in a directory.

**Usage:**
```bash
./scripts/linux/decrypt-all.sh <directory> <password>
```

**Examples:**
```bash
# Decrypt all files in sandbox
./scripts/linux/decrypt-all.sh sandbox MyPassword123!

# Decrypt backup files
./scripts/linux/decrypt-all.sh ~/encrypted-backup MyPassword123!

# With saved key
./scripts/linux/decrypt-all.sh sandbox -k backup-key -p MyPassword123!
```

**⚠️ Important:**
- Asks for confirmation before decrypting
- Decrypts ALL .encrypted files in directory
- Saves with .decrypted extension
- Be careful with the password!

**What it does:**
1. Finds all .encrypted files
2. Shows count and asks confirmation
3. Attempts to decrypt each file
4. Reports success/failure
5. Shows summary

---

### batch-decrypt.sh

**Purpose:** Selectively decrypt files matching a pattern.

**Usage:**
```bash
./scripts/linux/batch-decrypt.sh <directory> <pattern> <password>
```

**Examples:**
```bash
# Decrypt only PDF files
./scripts/linux/batch-decrypt.sh sandbox "*.pdf.encrypted" MyPass123!

# Decrypt files starting with 'photo'
./scripts/linux/batch-decrypt.sh ~/backup "photo*.encrypted" PhotoPass!

# Decrypt files from 2024
./scripts/linux/batch-decrypt.sh sandbox "*2024*.encrypted" BackupPass!

# Decrypt client files
./scripts/linux/batch-decrypt.sh sandbox "client-*.encrypted" ClientPass!
```

**Pattern examples:**
- `"*.pdf.encrypted"` - All PDF files
- `"photo*.encrypted"` - Files starting with 'photo'
- `"*2024*.encrypted"` - Files containing '2024'
- `"project-a-*.encrypted"` - Files starting with 'project-a-'

**What it does:**
1. Finds files matching pattern
2. Shows list of matched files
3. Asks for confirmation
4. Decrypts only matched files
5. Reports results

---

### cleanup-sandbox.sh

**Purpose:** Clean up old encrypted/decrypted files from sandbox.

**Usage:**
```bash
./scripts/linux/cleanup-sandbox.sh [days] [--dry-run]
```

**Examples:**
```bash
# Preview without deleting (older than 30 days)
./scripts/linux/cleanup-sandbox.sh --dry-run

# Delete files older than 30 days
./scripts/linux/cleanup-sandbox.sh

# Delete files older than 7 days
./scripts/linux/cleanup-sandbox.sh 7

# Preview files older than 7 days
./scripts/linux/cleanup-sandbox.sh 7 --dry-run
```

**Features:**
- `--dry-run` mode to preview
- Shows file sizes and dates
- Calculates space to be freed
- Asks for confirmation
- Only deletes .encrypted and .decrypted files

**What it does:**
1. Finds files older than X days
2. Lists files with sizes and dates
3. Shows total space to be freed
4. Asks for confirmation (unless dry-run)
5. Deletes files and reports results

**Use cases:**
- Regular sandbox maintenance
- Free up disk space
- Remove old test files
- Automated cleanup (with cron)

---

### rotate-passwords.sh

**Purpose:** Rotate passwords by re-encrypting all files.

**Usage:**
```bash
./scripts/linux/rotate-passwords.sh <directory> <old-password> <new-password>
```

**Examples:**
```bash
# Rotate password for sandbox
./scripts/linux/rotate-passwords.sh sandbox OldPass2023! NewPass2024!

# Rotate password for backup
./scripts/linux/rotate-passwords.sh ~/encrypted-files OldPass! NewPass!
```

**⚠️ CRITICAL:**
- Make backups before rotating!
- Process is irreversible
- Failed files keep old password
- Successful files use new password
- Test thoroughly before production use

**What it does:**
1. Finds all .encrypted files
2. For each file:
   - Decrypts with old password
   - Re-encrypts with new password
   - Replaces original encrypted file
3. Reports success/failure per file
4. Shows final summary

**Use cases:**
- Annual password rotation policy
- Security breach response
- Upgrading to stronger passwords
- Team member access changes

---

## ⚙️ Configuration

### Global Configuration

All scripts detect CryptVault path automatically:
```bash
CRYPTVAULT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
```

### Per-Script Configuration

Edit configuration section at top of each script:

```bash
# -------------------------------
# CONFIGURATION - EDIT THESE
# -------------------------------

BACKUP_DIR="$HOME/important-docs"
PASSWORD="YourPassword"
# ... more settings
```

### Using Environment Variables

For better security, use environment variables:

```bash
# Set password in environment
export CRYPT_PASSWORD="MySecurePassword123!"

# Modify script to use it
PASSWORD="${CRYPT_PASSWORD:-DefaultPassword}"
```

**Add to ~/.bashrc or ~/.zshrc for persistence:**
```bash
export CRYPT_PASSWORD="MySecurePassword123!"
```

---

## 📅 Scheduling with Cron

### Edit Crontab

```bash
crontab -e
```

### Common Schedules

```bash
# Daily at 2 AM
0 2 * * * /path/to/cryptvault/scripts/linux/daily-backup.sh

# Every Monday at 3 AM
0 3 * * 1 /path/to/cryptvault/scripts/linux/organized-backup.sh

# 1st of month at 3 AM
0 3 1 * * /path/to/cryptvault/scripts/linux/organized-backup.sh

# Every 6 hours
0 */6 * * * /path/to/cryptvault/scripts/linux/daily-backup.sh

# Every Sunday at midnight
0 0 * * 0 /path/to/cryptvault/scripts/linux/cleanup-sandbox.sh 30
```

### Cron Syntax

```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, 0 and 7 = Sunday)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

### Logging Output

```bash
# Redirect output to log file
0 2 * * * /path/to/script.sh >> /var/log/cryptvault.log 2>&1

# Email output (if mail configured)
0 2 * * * /path/to/script.sh
```

---

## 🔧 Customization

### Creating Custom Scripts

Use existing scripts as templates:

```bash
#!/bin/bash
# my-custom-backup.sh

# Configuration
CRYPTVAULT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PASSWORD="MyPassword"

# Your custom logic
for file in ~/my-special-files/*; do
    python "$CRYPTVAULT_PATH/src/file_encryption_sandbox.py" \
        encrypt "$file" -p "$PASSWORD"
done

echo "✅ Custom backup complete"
```

### Adding New Categories

Edit `organized-backup.sh`:

```bash
# Add your categories
declare -A CATEGORIES=(
    ["documents"]="$HOME/Documents/*.{pdf,docx}"
    ["my-category"]="$HOME/MyFolder/*.{ext1,ext2}"  # ADD THIS
)
```

---

## 🐛 Troubleshooting

### Script not executable

```bash
chmod +x scripts/linux/script-name.sh
```

### Permission denied

```bash
# Check file permissions
ls -l scripts/linux/

# Make executable
chmod +x scripts/linux/*.sh
```

### Command not found

```bash
# Use full path
/full/path/to/cryptvault/scripts/linux/daily-backup.sh

# Or add to PATH
export PATH="$PATH:/path/to/cryptvault/scripts/linux"
```

### Python not found

```bash
# Check Python installation
which python
which python3

# Use specific Python version in scripts
python3 "$CRYPTVAULT_PATH/src/file_encryption_sandbox.py" ...
```

### Cron job not running

```bash
# Check cron logs
grep CRON /var/log/syslog  # Ubuntu/Debian
grep CRON /var/log/cron     # CentOS/RHEL

# Use absolute paths in crontab
0 2 * * * /home/user/cryptvault/scripts/linux/daily-backup.sh

# Add environment variables
CRYPTVAULT_PATH=/home/user/cryptvault
0 2 * * * $CRYPTVAULT_PATH/scripts/linux/daily-backup.sh
```

### Script fails silently

```bash
# Run with bash -x for debug
bash -x scripts/linux/daily-backup.sh

# Add set -x to script for debugging
#!/bin/bash
set -x  # Add this line
# ... rest of script
```

---

## 🔒 Security Best Practices

### ✅ DO:
- Use strong, unique passwords
- Store passwords in environment variables
- Use `chmod 600` for scripts with passwords
- Review scripts before running
- Test on sample data first
- Keep scripts in secure locations
- Use `--dry-run` when available

### ❌ DON'T:
- Commit passwords to Git
- Share scripts with embedded passwords
- Run scripts as root unless necessary
- Skip backups before password rotation
- Use weak or default passwords

### Password Storage

```bash
# Good: Environment variable
export CRYPT_PASSWORD="SecurePass123!"

# Bad: Hardcoded in script
PASSWORD="SecurePass123!"  # Don't do this!

# Better: Prompt for password
read -sp "Enter password: " PASSWORD
echo
```

---

## 📚 Additional Resources

- **Main Documentation:** [../../docs/](../../docs/)
- **Usage Guide:** [../../docs/USAGE.md](../../docs/USAGE.md)
- **Examples:** [../../docs/EXAMPLES.md](../../docs/EXAMPLES.md)
- **Windows Scripts:** [../windows/](../windows/)
- **Parent README:** [../README.md](../README.md)

---

## 🤝 Contributing

Improvements and new scripts welcome!

1. Follow existing script format
2. Add configuration section at top
3. Include usage examples in comments
4. Test thoroughly
5. Update this README

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/pawored/cryptvault/issues)
- **Email:** zogoxi-gobo52@protonmail.com
- **Documentation:** [docs/](../../docs/)

---

<div align="center">

**Happy automating! 🐧**

[← Back to Scripts](../README.md) • [Windows Scripts →](../windows/)

</div>
