# 🔧 Automation Scripts

Utility scripts for common CryptVault tasks across different platforms.

---

## 📋 Script Organization

```
scripts/
├── README.md                    # This file
├── verify-encryption.py         # Cross-platform (Python)
│
├── linux/                       # Bash scripts (Linux/Mac)
│   ├── daily-backup.sh
│   ├── encrypt-by-type.sh
│   ├── organized-backup.sh
│   ├── decrypt-all.sh
│   ├── batch-decrypt.sh
│   ├── cleanup-sandbox.sh
│   └── rotate-passwords.sh
│
└── windows/                     # PowerShell scripts (Windows)
    ├── daily-backup.ps1
    ├── encrypt-by-type.ps1
    ├── organized-backup.ps1
    ├── decrypt-all.ps1
    ├── batch-decrypt.ps1
    ├── cleanup-sandbox.ps1
    └── rotate-passwords.ps1
```

---

## 🐧 Linux/Mac Scripts

Located in `scripts/linux/`

### Quick Start

```bash
# Make executable
chmod +x scripts/linux/*.sh

# Run any script
./scripts/linux/daily-backup.sh
./scripts/linux/encrypt-by-type.sh pdf MyPassword123!
```

### Available Scripts

| Script | Description |
|--------|-------------|
| **daily-backup.sh** | Automated daily backup |
| **encrypt-by-type.sh** | Encrypt files by extension |
| **organized-backup.sh** | Organized category backups |
| **decrypt-all.sh** | Decrypt all files in directory |
| **batch-decrypt.sh** | Selective batch decryption |
| **cleanup-sandbox.sh** | Clean old files |
| **rotate-passwords.sh** | Rotate encryption passwords |

See [linux/README.md](linux/README.md) for detailed documentation.

---

## 🪟 Windows Scripts

Located in `scripts/windows/`

### Quick Start

```powershell
# Enable script execution (run once)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run any script
.\scripts\windows\daily-backup.ps1
.\scripts\windows\encrypt-by-type.ps1 pdf MyPassword123!
```

### Available Scripts

| Script | Description |
|--------|-------------|
| **daily-backup.ps1** | Automated daily backup |
| **encrypt-by-type.ps1** | Encrypt files by extension |
| **organized-backup.ps1** | Organized category backups |
| **decrypt-all.ps1** | Decrypt all files in directory |
| **batch-decrypt.ps1** | Selective batch decryption |
| **cleanup-sandbox.ps1** | Clean old files |
| **rotate-passwords.ps1** | Rotate encryption passwords |

See [windows/README.md](windows/README.md) for detailed documentation.

---

## 🐍 Cross-Platform Scripts

### verify-encryption.py

Works on all platforms (requires Python).

**Purpose:** Verify that encrypted files can be decrypted.

**Usage:**
```bash
# Linux/Mac
python3 scripts/verify-encryption.py MyPassword123!

# Windows
python scripts\verify-encryption.py MyPassword123!

# With directory
python scripts/verify-encryption.py MyPassword123! sandbox
python scripts/verify-encryption.py MyPassword123! C:\backup\encrypted
```

**What it does:**
1. Finds all .encrypted files
2. Attempts to decrypt each one
3. Reports success/failure
4. Shows summary statistics

---

## 🚀 Quick Examples

### Linux/Mac

```bash
# Daily backup
./scripts/linux/daily-backup.sh

# Encrypt all PDFs
./scripts/linux/encrypt-by-type.sh pdf MyPassword123! ~/Documents

# Verify encryption
python3 scripts/verify-encryption.py MyPassword123!

# Clean old files
./scripts/linux/cleanup-sandbox.sh 30 --dry-run

# Rotate passwords
./scripts/linux/rotate-passwords.sh sandbox OldPass! NewPass!
```

### Windows

```powershell
# Daily backup
.\scripts\windows\daily-backup.ps1

# Encrypt all PDFs
.\scripts\windows\encrypt-by-type.ps1 pdf MyPassword123! C:\Users\Me\Documents

# Verify encryption
python scripts\verify-encryption.py MyPassword123!

# Clean old files
.\scripts\windows\cleanup-sandbox.ps1 -Days 30 -DryRun

# Rotate passwords
.\scripts\windows\rotate-passwords.ps1 sandbox OldPass! NewPass!
```

---

## 📚 Detailed Documentation

### Platform-Specific Guides

- **Linux/Mac:** [linux/README.md](linux/README.md)
- **Windows:** [windows/README.md](windows/README.md)

### General Topics

- [Installation](../docs/INSTALLATION.md)
- [Usage Guide](../docs/USAGE.md)
- [Examples](../docs/EXAMPLES.md)

---

## ⚙️ Configuration

Most scripts have configuration sections at the top. Edit these before first use:

### Bash Scripts (Linux/Mac)

```bash
# Open script in editor
nano scripts/linux/daily-backup.sh

# Edit configuration section
BACKUP_DIR="$HOME/important-docs"  # Your backup source
PASSWORD="YourPassword"             # Your password
```

### PowerShell Scripts (Windows)

```powershell
# Open script in editor
notepad scripts\windows\daily-backup.ps1

# Edit configuration section
$BackupDir = "$env:USERPROFILE\Documents"
$Password = "YourPassword"
```

---

## 🔒 Security Best Practices

### ⚠️ Important

1. **Never commit scripts with passwords to Git**
2. **Use environment variables for sensitive data**
3. **Keep scripts in secure locations**
4. **Review scripts before running**
5. **Test on sample data first**

### Using Environment Variables

**Linux/Mac:**
```bash
# Set environment variable
export CRYPT_PASSWORD="MyPassword123!"

# Use in script
PASSWORD="${CRYPT_PASSWORD:-DefaultPass}"
```

**Windows:**
```powershell
# Set environment variable
$env:CRYPT_PASSWORD = "MyPassword123!"

# Use in script
$Password = $env:CRYPT_PASSWORD
```

---

## 📅 Scheduling Scripts

### Linux/Mac (cron)

```bash
# Edit crontab
crontab -e

# Examples:
0 2 * * * /path/to/scripts/linux/daily-backup.sh           # Daily at 2 AM
0 3 1 * * /path/to/scripts/linux/organized-backup.sh       # Monthly
*/30 * * * * python3 /path/to/scripts/verify-encryption.py  # Every 30 min
```

### Windows (Task Scheduler)

**GUI Method:**
1. Open Task Scheduler
2. Create Basic Task
3. Set trigger (daily, weekly, etc.)
4. Action: Start a program
5. Program: `PowerShell.exe`
6. Arguments: `-File C:\path\to\scripts\windows\daily-backup.ps1`

**PowerShell Method:**
```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File C:\path\to\scripts\windows\daily-backup.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 2am

Register-ScheduledTask -TaskName "CryptVault Daily Backup" `
    -Action $action -Trigger $trigger
```

---

## 🛠️ Customization

### Creating Custom Scripts

Use existing scripts as templates:

**Bash (Linux/Mac):**
```bash
#!/bin/bash
# my-custom-script.sh

CRYPTVAULT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PASSWORD="MyPassword"

# Your logic here
for file in ~/my-files/*; do
    python "$CRYPTVAULT_PATH/src/file_encryption_sandbox.py" encrypt "$file" -p "$PASSWORD"
done
```

**PowerShell (Windows):**
```powershell
# my-custom-script.ps1

$CryptVaultPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Password = "MyPassword"

# Your logic here
Get-ChildItem "$env:USERPROFILE\my-files" | ForEach-Object {
    python "$CryptVaultPath\src\file_encryption_sandbox.py" encrypt $_.FullName -p $Password
}
```

---

## 🐛 Troubleshooting

### Linux/Mac

**Script not executable:**
```bash
chmod +x scripts/linux/script-name.sh
```

**Command not found:**
```bash
# Use full path
/path/to/cryptvault/scripts/linux/daily-backup.sh

# Or add to PATH
export PATH="$PATH:/path/to/cryptvault/scripts/linux"
```

### Windows

**Execution policy error:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Path issues:**
```powershell
# Use full paths in scripts
$CryptVaultPath = "C:\Users\Me\cryptvault"
```

**Python not found:**
```powershell
# Use full path to Python
& "C:\Python39\python.exe" scripts\verify-encryption.py
```

---

## 🤝 Contributing Scripts

Have a useful script? Share it!

1. **Test thoroughly** on your platform
2. **Add comments** explaining what it does
3. **Follow naming convention:** `verb-noun.sh` or `verb-noun.ps1`
4. **Update README** with documentation
5. **Submit pull request**

See [CONTRIBUTING.md](../docs/CONTRIBUTING.md) for details.

---

## 📞 Support

- **Platform Issues:** Check platform-specific README
  - [linux/README.md](linux/README.md)
  - [windows/README.md](windows/README.md)
- **General Issues:** [TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md)
- **Bug Reports:** [GitHub Issues](https://github.com/pawored/cryptvault/issues)
- **Email:** zogoxi-gobo52@protonmail.com

---

<div align="center">

**Choose your platform and start automating!**

[Linux/Mac Scripts](linux/) • [Windows Scripts](windows/) • [Documentation](../docs/)

</div>
