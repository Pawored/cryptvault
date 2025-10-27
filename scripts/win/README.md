# 🪟 Windows Scripts

PowerShell automation scripts for CryptVault on Windows.

---

## 📋 Available Scripts

| Script | Description | Difficulty |
|--------|-------------|------------|
| [daily-backup.ps1](#daily-backupps1) | Automated daily backup | ⭐ Easy |
| [encrypt-by-type.ps1](#encrypt-by-typeps1) | Encrypt by file extension | ⭐ Easy |
| [organized-backup.ps1](#organized-backupps1) | Organized category backups | ⭐⭐ Medium |
| [decrypt-all.ps1](#decrypt-allps1) | Decrypt all files | ⭐ Easy |
| [batch-decrypt.ps1](#batch-decryptps1) | Selective batch decryption | ⭐⭐ Medium |
| [cleanup-sandbox.ps1](#cleanup-sandboxps1) | Clean old files | ⭐ Easy |
| [rotate-passwords.ps1](#rotate-passwordsps1) | Rotate passwords | ⭐⭐⭐ Advanced |

---

## 🚀 Quick Start

### Enable Script Execution

**Required:** Run this once (as Administrator or for current user):

```powershell
# For current user only (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or for all users (requires Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

### Run a Script

```powershell
# From project root
.\scripts\windows\daily-backup.ps1

# Or navigate to scripts\windows
cd scripts\windows
.\daily-backup.ps1

# With parameters
.\encrypt-by-type.ps1 -Extension pdf -Password MyPass123!
```

---

## 📚 Script Documentation

### daily-backup.ps1

**Purpose:** Automatically encrypt and backup files daily.

**Configuration:**
Edit these variables in the script:
```powershell
$BackupDir = "$env:USERPROFILE\Documents\important-docs"
$KeyName = "daily-backup"
$Password = "DailyBackup2024!"  # CHANGE THIS!
$BackupRoot = "C:\backup\encrypted"
```

**Usage:**
```powershell
# Run manually
.\scripts\windows\daily-backup.ps1

# Schedule with Task Scheduler (see below)
```

**What it does:**
1. Scans source directory for files
2. Encrypts each file with specified password
3. Saves encrypted files to dated backup folder
4. Shows colored summary (green/red/yellow)

**Example output:**
```
==========================================
CryptVault Daily Backup
==========================================
Backup source: C:\Users\Me\Documents\important-docs
Backup destination: C:\backup\encrypted\20241027

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

### encrypt-by-type.ps1

**Purpose:** Encrypt all files of a specific type in a directory.

**Parameters:**
- `-Extension` (required) - File extension without dot
- `-Password` (required) - Encryption password
- `-Directory` (optional) - Directory to search (default: current)

**Usage:**
```powershell
.\scripts\windows\encrypt-by-type.ps1 -Extension pdf -Password MyPassword123!

# With custom directory
.\scripts\windows\encrypt-by-type.ps1 -Extension pdf -Password MyPass123! -Directory C:\Users\Me\Documents

# Shorter syntax (positional)
.\scripts\windows\encrypt-by-type.ps1 pdf MyPassword123! C:\Users\Me\Documents
```

**Examples:**
```powershell
# Encrypt all PDFs in Documents
.\scripts\windows\encrypt-by-type.ps1 pdf MyPass123! "$env:USERPROFILE\Documents"

# Encrypt all JPGs in Pictures
.\scripts\windows\encrypt-by-type.ps1 jpg PhotoPass2024! "$env:USERPROFILE\Pictures"

# Encrypt all DOCX files in current directory
.\scripts\windows\encrypt-by-type.ps1 docx WorkPass!
```

**What it does:**
1. Recursively searches for files with specified extension
2. Encrypts each file found
3. Saves to sandbox directory
4. Reports success/failure with colored output

---

### organized-backup.ps1

**Purpose:** Create organized backups by category (documents, photos, videos, etc.).

**Configuration:**
Edit the categories hashtable in the script:
```powershell
$Categories = @{
    "documents" = @{
        "Path" = "$env:USERPROFILE\Documents"
        "Extensions" = @("*.pdf", "*.docx", "*.xlsx")
    }
    "photos" = @{
        "Path" = "$env:USERPROFILE\Pictures"
        "Extensions" = @("*.jpg", "*.png")
    }
    # Add more categories...
}
```

**Usage:**
```powershell
# Run manually
.\scripts\windows\organized-backup.ps1

# Schedule with Task Scheduler (see below)
```

**Directory structure created:**
```
C:\backup\encrypted\
├── documents\
│   └── 2024-10-27\
│       ├── file1.pdf.enc
│       └── file2.docx.enc
├── photos\
│   └── 2024-10-27\
│       └── photo1.jpg.enc
└── videos\
    └── 2024-10-27\
        └── video1.mp4.enc
```

**What it does:**
1. Processes each category separately
2. Finds files matching patterns
3. Encrypts files with same password
4. Organizes in dated category folders
5. Creates backup log with timestamp

---

### decrypt-all.ps1

**Purpose:** Decrypt all .encrypted files in a directory.

**Parameters:**
- `-Directory` (required) - Directory containing encrypted files
- `-Password` (required) - Decryption password
- `-KeyName` (optional) - Name of saved key to use

**Usage:**
```powershell
# Basic usage
.\scripts\windows\decrypt-all.ps1 -Directory sandbox -Password MyPassword123!

# With full path
.\scripts\windows\decrypt-all.ps1 -Directory "C:\encrypted-backup" -Password MyPass123!

# Using saved key
.\scripts\windows\decrypt-all.ps1 -Directory sandbox -KeyName backup-key -Password MyPass123!
```

**⚠️ Important:**
- Asks for confirmation before decrypting
- Decrypts ALL .encrypted files in directory
- Saves with .decrypted extension
- Be careful with the password!

**What it does:**
1. Finds all .encrypted files in directory
2. Shows count and asks for confirmation
3. Attempts to decrypt each file
4. Reports success/failure with colors
5. Shows final summary

---

### batch-decrypt.ps1

**Purpose:** Selectively decrypt files matching a pattern.

**Parameters:**
- `-Directory` (required) - Directory to search
- `-Pattern` (required) - Wildcard pattern to match
- `-Password` (required) - Decryption password

**Usage:**
```powershell
# Decrypt only PDF files
.\scripts\windows\batch-decrypt.ps1 -Directory sandbox -Pattern "*.pdf.encrypted" -Password MyPass123!

# Decrypt files starting with 'photo'
.\scripts\windows\batch-decrypt.ps1 -Directory C:\backup -Pattern "photo*.encrypted" -Password PhotoPass!

# Decrypt files from 2024
.\scripts\windows\batch-decrypt.ps1 -Directory sandbox -Pattern "*2024*.encrypted" -Password BackupPass!
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
5. Reports results with colors

---

### cleanup-sandbox.ps1

**Purpose:** Clean up old encrypted/decrypted files from sandbox.

**Parameters:**
- `-Days` (optional) - Delete files older than X days (default: 30)
- `-DryRun` (switch) - Preview without deleting

**Usage:**
```powershell
# Preview files older than 30 days (no deletion)
.\scripts\windows\cleanup-sandbox.ps1 -DryRun

# Delete files older than 30 days
.\scripts\windows\cleanup-sandbox.ps1

# Delete files older than 7 days
.\scripts\windows\cleanup-sandbox.ps1 -Days 7

# Preview files older than 7 days
.\scripts\windows\cleanup-sandbox.ps1 -Days 7 -DryRun
```

**Features:**
- `-DryRun` mode to preview changes
- Shows file sizes (KB/MB)
- Shows modification dates
- Calculates space to be freed
- Asks for confirmation
- Only affects .encrypted and .decrypted files

**What it does:**
1. Finds files older than specified days
2. Lists files with sizes and dates
3. Shows total space to be freed
4. Asks for confirmation (unless dry-run)
5. Deletes files and reports results

**Use cases:**
- Regular sandbox maintenance
- Free up disk space
- Remove old test files
- Automated cleanup (with Task Scheduler)

---

### rotate-passwords.ps1

**Purpose:** Rotate passwords by re-encrypting all files.

**Parameters:**
- `-Directory` (required) - Directory containing encrypted files
- `-OldPassword` (required) - Current password
- `-NewPassword` (required) - New password to use

**Usage:**
```powershell
# Rotate password for sandbox
.\scripts\windows\rotate-passwords.ps1 -Directory sandbox -OldPassword OldPass2023! -NewPassword NewPass2024!

# Rotate password for backup
.\scripts\windows\rotate-passwords.ps1 -Directory "C:\encrypted-files" -OldPassword OldPass! -NewPassword NewPass!
```

**⚠️ CRITICAL:**
- Make backups before rotating!
- Process is irreversible
- Failed files keep old password
- Successful files use new password
- Test thoroughly before production use

**What it does:**
1. Finds all .encrypted files
2. Creates temporary directory
3. For each file:
   - Decrypts with old password
   - Re-encrypts with new password
   - Replaces original encrypted file
4. Cleans up temporary files
5. Reports success/failure per file
6. Shows final summary

**Use cases:**
- Annual password rotation policy
- Security breach response
- Upgrading to stronger passwords
- Team member access changes

---

## ⚙️ Configuration

### Per-Script Configuration

Edit configuration section at top of each script:

```powershell
# -------------------------------
# CONFIGURATION - EDIT THESE
# -------------------------------

$BackupDir = "$env:USERPROFILE\Documents\important-docs"
$Password = "YourPassword"
# ... more settings
```

### Using Environment Variables

For better security, use environment variables:

```powershell
# Set password in environment
$env:CRYPT_PASSWORD = "MySecurePassword123!"

# Modify script to use it
$Password = if ($env:CRYPT_PASSWORD) { $env:CRYPT_PASSWORD } else { "DefaultPassword" }
```

**Add to PowerShell profile for persistence:**
```powershell
# Edit profile
notepad $PROFILE

# Add line:
$env:CRYPT_PASSWORD = "MySecurePassword123!"
```

---

## 📅 Scheduling with Task Scheduler

### Method 1: GUI (Easy)

1. Open **Task Scheduler** (search in Start menu)
2. Click **Create Basic Task**
3. Name: "CryptVault Daily Backup"
4. Trigger: **Daily** at **2:00 AM**
5. Action: **Start a program**
   - Program: `PowerShell.exe`
   - Arguments: `-File "C:\path\to\cryptvault\scripts\windows\daily-backup.ps1"`
6. Click **Finish**

### Method 2: PowerShell (Advanced)

```powershell
# Create daily backup task
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File C:\path\to\cryptvault\scripts\windows\daily-backup.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 2am

Register-ScheduledTask -TaskName "CryptVault Daily Backup" `
    -Action $action -Trigger $trigger -Description "Daily encrypted backup"
```

### Common Schedules

```powershell
# Daily at 2 AM
$trigger = New-ScheduledTaskTrigger -Daily -At 2am

# Weekly on Monday at 3 AM
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 3am

# Monthly on 1st at 3 AM
$trigger = New-ScheduledTaskTrigger -Monthly -DaysOfMonth 1 -At 3am

# Every 6 hours
$trigger = New-ScheduledTaskTrigger -Once -At 12am -RepetitionInterval (New-TimeSpan -Hours 6) -RepetitionDuration ([TimeSpan]::MaxValue)
```

### View/Manage Tasks

```powershell
# List all CryptVault tasks
Get-ScheduledTask | Where-Object {$_.TaskName -like "*CryptVault*"}

# Run task manually
Start-ScheduledTask -TaskName "CryptVault Daily Backup"

# Disable task
Disable-ScheduledTask -TaskName "CryptVault Daily Backup"

# Remove task
Unregister-ScheduledTask -TaskName "CryptVault Daily Backup" -Confirm:$false
```

---

## 🔧 Customization

### Creating Custom Scripts

Use existing scripts as templates:

```powershell
# my-custom-backup.ps1

# Configuration
$CryptVaultPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Password = "MyPassword"

# Your custom logic
Get-ChildItem "$env:USERPROFILE\my-special-files" | ForEach-Object {
    python "$CryptVaultPath\src\file_encryption_sandbox.py" `
        encrypt $_.FullName -p $Password
}

Write-Host "✅ Custom backup complete" -ForegroundColor Green
```

### Adding New Categories

Edit `organized-backup.ps1`:

```powershell
# Add your categories to the hashtable
$Categories = @{
    "documents" = @{
        "Path" = "$env:USERPROFILE\Documents"
        "Extensions" = @("*.pdf", "*.docx")
    }
    "my-category" = @{
        "Path" = "C:\MyFolder"
        "Extensions" = @("*.ext1", "*.ext2")
    }
}
```

---

## 🐛 Troubleshooting

### Execution Policy Error

```powershell
# Error: "execution of scripts is disabled on this system"

# Solution: Enable for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify
Get-ExecutionPolicy
```

### Python Not Found

```powershell
# Check Python installation
python --version
Get-Command python

# If not in PATH, use full path in scripts:
$PythonPath = "C:\Python39\python.exe"
& $PythonPath "$CryptVaultPath\src\file_encryption_sandbox.py" ...
```

### Script Runs But Does Nothing

```powershell
# Check for errors
$Error[0]  # Show last error

# Run with verbose output
.\script.ps1 -Verbose

# Check Python errors
Get-Content "$env:TEMP\crypt_err.txt"
```

### Task Scheduler Not Running

```powershell
# Check task status
Get-ScheduledTask -TaskName "CryptVault*" | Select-Object TaskName, State, LastRunTime

# Check task history
Get-ScheduledTask -TaskName "CryptVault Daily Backup" | Get-ScheduledTaskInfo

# Use absolute paths in task
# ❌ Bad: .\scripts\windows\daily-backup.ps1
# ✅ Good: C:\Users\Me\cryptvault\scripts\windows\daily-backup.ps1
```

### Permission Denied

```powershell
# Run PowerShell as Administrator (if needed)
Start-Process powershell -Verb RunAs

# Or check file permissions
Get-Acl .\script.ps1 | Format-List
```

---

## 🔒 Security Best Practices

### ✅ DO:
- Use strong, unique passwords
- Store passwords in environment variables
- Review scripts before running
- Test on sample data first
- Use `-DryRun` when available
- Keep scripts in secure locations
- Set restricted permissions on script files

### ❌ DON'T:
- Commit passwords to Git
- Share scripts with embedded passwords
- Run scripts with Administrator privileges unnecessarily
- Skip backups before password rotation
- Use weak or default passwords
- Store passwords in plain text files

### Password Storage

```powershell
# Good: Environment variable
$env:CRYPT_PASSWORD = "SecurePass123!"

# Bad: Hardcoded in script
$Password = "SecurePass123!"  # Don't do this!

# Better: Secure prompt (for interactive use)
$Password = Read-Host "Enter password" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
```

---

## 💡 Tips and Tricks

### Color Output

Scripts use colored output:
- 🟢 Green = Success
- 🔴 Red = Error
- 🟡 Yellow = Warning
- 🔵 Cyan = Info

### Progress Indication

All scripts show progress:
```
[1/10] Processing file1.txt
[2/10] Processing file2.txt
...
```

### Error Logs

Errors are redirected to:
```
$env:TEMP\crypt_err.txt
```

Check this file if scripts fail silently.

### Testing

Always test with `-DryRun` (when available):
```powershell
.\cleanup-sandbox.ps1 -Days 30 -DryRun
```

---

## 📚 Additional Resources

- **Main Documentation:** [../../docs/](../../docs/)
- **Usage Guide:** [../../docs/USAGE.md](../../docs/USAGE.md)
- **Examples:** [../../docs/EXAMPLES.md](../../docs/EXAMPLES.md)
- **Linux Scripts:** [../linux/](../linux/)
- **Parent README:** [../README.md](../README.md)

---

## 🤝 Contributing

Improvements and new scripts welcome!

1. Follow existing script format
2. Use proper PowerShell conventions
3. Add parameter documentation
4. Include usage examples
5. Test thoroughly on Windows 10/11
6. Update this README

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/pawored/cryptvault/issues)
- **Email:** zogoxi-gobo52@protonmail.com
- **Documentation:** [docs/](../../docs/)

---

<div align="center">

**Happy automating! 🪟**

[← Back to Scripts](../README.md) • [Linux Scripts →](../linux/)

</div>
