# 🔧 Troubleshooting

Common issues and solutions for CryptVault.

---

## Table of Contents

- [Installation Issues](#installation-issues)
- [Execution Issues](#execution-issues)
- [Encryption/Decryption Issues](#encryptiondecryption-issues)
- [Script Issues](#script-issues)
- [Performance Issues](#performance-issues)

---

## Installation Issues

### Python Not Found

**Error:** `python: command not found`

**Solutions:**
```bash
# Try python3 instead
python3 --version

# Add alias (Linux/Mac)
echo "alias python=python3" >> ~/.bashrc
source ~/.bashrc

# Windows - use py launcher
py --version
```

---

### Module 'cryptography' Not Found

**Error:** `ModuleNotFoundError: No module named 'cryptography'`

**Solution:**
```bash
# Install dependencies
pip install -r config/requirements.txt

# Or install directly
pip install cryptography
```

**If still failing:**
```bash
# Use pip3 instead
pip3 install cryptography

# Or with user flag
pip install --user cryptography

# Check Python version (need 3.7+)
python --version
```

---

### Permission Denied During Install

**Error:** `Permission denied` when installing

**Solutions:**
```bash
# Option 1: User install
pip install --user cryptography

# Option 2: Virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
pip install -r config/requirements.txt

# Option 3: Use sudo (not recommended)
sudo pip install cryptography
```

---

## Execution Issues

### Command Not Found

**Error:** `cryptvault: command not found`

**Solution:**
CryptVault isn't in PATH. Use full path:

```bash
# From project root
cryptvault encrypt file.pdf -p Pass123!

# Or navigate to src
cd src
python file_encryption_sandbox.py encrypt file.pdf -p Pass123!
```

---

### Script Not Executable (Linux/Mac)

**Error:** `Permission denied`

**Solution:**
```bash
# Make executable
chmod +x scripts/linux/*.sh

# Run script
./scripts/linux/daily-backup.sh
```

---

### PowerShell Execution Policy (Windows)

**Error:** `cannot be loaded because running scripts is disabled`

**Solution:**
```powershell
# Enable script execution (as Administrator or for current user)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify
Get-ExecutionPolicy
```

---

## Encryption/Decryption Issues

### Wrong Password Error

**Error:** `Decryption failed: Invalid token or wrong password`

**Possible Causes:**
1. Incorrect password (typo)
2. File encrypted with different password
3. Corrupted file
4. Caps Lock on

**Solutions:**
```bash
# Try again carefully
cryptvault decrypt file.encrypted -p CorrectPassword!

# Check Caps Lock and keyboard layout

# Verify file integrity
ls -lh file.encrypted  # Should have size > 0
```

**Tip:** Use password manager to avoid typos

---

### File Already Exists

**Error:** `File already exists: sandbox/file.pdf.encrypted`

**Solutions:**

**Option 1:** Use different output name
```bash
cryptvault encrypt file.pdf -p Pass! -o file-backup.encrypted
```

**Option 2:** Delete existing file
```bash
rm sandbox/file.pdf.encrypted
cryptvault encrypt file.pdf -p Pass!
```

**Option 3:** Force overwrite (if implemented)
```bash
cryptvault encrypt file.pdf -p Pass! --force
```

---

### Input File Not Found

**Error:** `FileNotFoundError: [Errno 2] No such file or directory`

**Solutions:**

**Check file path:**
```bash
# Verify file exists
ls -l myfile.pdf

# Use full path
cryptvault encrypt /full/path/to/file.pdf -p Pass!

# Or navigate to file directory
cd /path/to/files
python /path/to/cryptvault/src/file_encryption_sandbox.py encrypt file.pdf -p Pass!
```

---

### Corrupted Encrypted File

**Symptoms:**
- Decryption fails
- "Invalid token" error
- File size is 0 or very small

**Diagnosis:**
```bash
# Check file size
ls -lh file.encrypted

# Check file type
file file.encrypted  # Should show "data"
```

**Solutions:**
- Restore from backup
- File may be unrecoverable if corrupted
- Prevention: Verify encryption before deleting originals

---

### Key File Not Found

**Error:** `KeyNotFoundError: Key 'my-key' not found`

**Solutions:**
```bash
# List available keys
ls config/*.key

# Verify key name (without .key extension)
cryptvault list-keys

# Create key if missing
cryptvault generate-key -n my-key -p MyPassword!
```

---

## Script Issues

### Bash Script Syntax Errors (Linux/Mac)

**Error:** `syntax error near unexpected token`

**Possible Causes:**
- Windows line endings (CRLF vs LF)
- Missing shebang line
- Shell incompatibility

**Solutions:**
```bash
# Convert line endings
dos2unix scripts/linux/daily-backup.sh

# Or using sed
sed -i 's/\r$//' scripts/linux/daily-backup.sh

# Verify shebang
head -n 1 scripts/linux/daily-backup.sh
# Should show: #!/bin/bash

# Run with bash explicitly
bash scripts/linux/daily-backup.sh
```

---

### PowerShell Script Errors (Windows)

**Error:** Various PowerShell errors

**Solutions:**
```powershell
# Check syntax
Get-Content scripts\windows\daily-backup.ps1

# Run with full path
& "C:\full\path\to\scripts\windows\daily-backup.ps1"

# Check PowerShell version (need 5.1+)
$PSVersionTable.PSVersion
```

---

### Cron Job Not Running (Linux/Mac)

**Symptoms:** Scheduled script doesn't execute

**Diagnosis:**
```bash
# Check cron logs
grep CRON /var/log/syslog  # Ubuntu/Debian
grep CRON /var/log/cron     # CentOS/RHEL

# Verify crontab entry
crontab -l
```

**Solutions:**
```bash
# Use absolute paths
# ❌ Bad: ./scripts/linux/daily-backup.sh
# ✅ Good: /home/user/cryptvault/scripts/linux/daily-backup.sh

# Add environment variables
# Edit crontab
crontab -e

# Add at top:
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
CRYPTVAULT_PATH=/home/user/cryptvault

# Then your cron job
0 2 * * * $CRYPTVAULT_PATH/scripts/linux/daily-backup.sh >> /var/log/cryptvault.log 2>&1

# Test script manually first
/home/user/cryptvault/scripts/linux/daily-backup.sh
```

---

### Task Scheduler Not Running (Windows)

**Symptoms:** Scheduled task doesn't execute

**Solutions:**
```powershell
# Check task status
Get-ScheduledTask -TaskName "CryptVault*" | Select-Object TaskName, State, LastRunTime

# View task history
Get-ScheduledTask -TaskName "CryptVault Backup" | Get-ScheduledTaskInfo

# Use absolute paths in task
# ❌ Bad: .\scripts\windows\daily-backup.ps1
# ✅ Good: C:\Users\Me\cryptvault\scripts\windows\daily-backup.ps1

# Run task manually to test
Start-ScheduledTask -TaskName "CryptVault Backup"

# Check last run result
(Get-ScheduledTask -TaskName "CryptVault Backup").LastTaskResult
# 0 = Success
# Non-zero = Error code
```

---

## Performance Issues

### Slow Encryption

**Symptoms:** Encryption takes very long

**Causes:**
- Large file size
- Slow disk (HDD vs SSD)
- High PBKDF2 iterations
- System resources

**Solutions:**
```bash
# Monitor progress
# Add verbose flag (if implemented)
cryptvault encrypt largefile.zip -p Pass! -v

# For very large files, consider:
# 1. Split file
split -b 500M largefile.zip largefile.part-

# 2. Encrypt parts
for part in largefile.part-*; do
    cryptvault encrypt $part -p Pass!
done

# 3. Combine encrypted parts later
cat *.encrypted > largefile.zip.encrypted
```

---

### High Memory Usage

**Symptoms:** System slows down during encryption

**Cause:** Large files loaded into memory

**Solutions:**
- Close other applications
- Encrypt during low-usage times
- Use batch processing for multiple small files instead of one large file
- Consider splitting large files

---

### Disk Space Issues

**Error:** `OSError: [Errno 28] No space left on device`

**Solutions:**
```bash
# Check disk space
df -h

# Clean up old encrypted files
./scripts/linux/cleanup-sandbox.sh 30 --dry-run  # Preview
./scripts/linux/cleanup-sandbox.sh 30             # Actually delete

# Delete originals after verifying encryption
# But ONLY after verifying!
cryptvault decrypt file.encrypted -p Pass!
diff file.pdf file.pdf.decrypted  # Verify identical
rm file.pdf  # Delete original
```

---

## Common Errors and Solutions

### "Invalid token"
- **Cause:** Wrong password or corrupted file
- **Solution:** Verify password, check file integrity

### "No module named 'cryptography'"
- **Cause:** Missing dependency
- **Solution:** `pip install -r config/requirements.txt`

### "Permission denied"
- **Cause:** Insufficient permissions
- **Solution:** Check file permissions, use `chmod` or run as admin

### "Command not found"
- **Cause:** Not in PATH or typo
- **Solution:** Use full path or add to PATH

### "Script not executable"
- **Cause:** Missing execute permission (Linux/Mac)
- **Solution:** `chmod +x script.sh`

---

## Getting More Help

### Enable Debug Mode

```bash
# Run with Python traceback
python -u src/file_encryption_sandbox.py encrypt file.pdf -p Pass!

# Or add debug prints in code
```

### Collect Information

When reporting issues, include:
1. Operating system and version
2. Python version (`python --version`)
3. CryptVault version
4. Full error message
5. Command you ran
6. Steps to reproduce

### Contact Support

- **GitHub Issues:** [github.com/pawored/cryptvault/issues](https://github.com/pawored/cryptvault/issues)
- **Email:** zogoxi-gobo52@protonmail.com
- **Documentation:** [docs/](README.md)

---

## Additional Resources

- [Installation Guide](INSTALLATION.md)
- [Usage Guide](USAGE.md)
- [FAQ](FAQ.md)
- [Examples](EXAMPLES.md)

---

<div align="center">

**Still stuck? Open an issue on GitHub! 🛠️**

[← Back to Documentation](README.md)

</div>
