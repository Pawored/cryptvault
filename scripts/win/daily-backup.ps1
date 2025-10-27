# ==============================================================================
# CryptVault - Daily Backup Script (PowerShell)
# ==============================================================================
#
# Automatically encrypts and backs up important files daily
#
# Usage:
#   .\scripts\windows\daily-backup.ps1
#
# Schedule with Task Scheduler:
#   - Open Task Scheduler
#   - Create Basic Task
#   - Trigger: Daily at 2:00 AM
#   - Action: Start PowerShell with this script
#
# ==============================================================================

# -------------------------------
# CONFIGURATION - EDIT THESE
# -------------------------------

# Source directory to backup
$BackupDir = "$env:USERPROFILE\Documents\important-docs"

# Key name for encryption
$KeyName = "daily-backup"

# Password for encryption (CHANGE THIS!)
$Password = "DailyBackup2024!"

# Destination for encrypted files
$BackupRoot = "C:\backup\encrypted"

# Date format for backup folders
$Date = Get-Date -Format "yyyyMMdd"

# Path to CryptVault (auto-detected)
$CryptVaultPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# -------------------------------
# SCRIPT START
# -------------------------------

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "CryptVault Daily Backup" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Create destination directory
$Destination = Join-Path $BackupRoot $Date
if (!(Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
}

Write-Host "Backup source: $BackupDir"
Write-Host "Backup destination: $Destination"
Write-Host ""

# Check if source directory exists
if (!(Test-Path $BackupDir)) {
    Write-Host "❌ Error: Source directory does not exist: $BackupDir" -ForegroundColor Red
    exit 1
}

# Statistics
$FileCount = 0
$SuccessCount = 0
$FailCount = 0

# Get all files in backup directory
$Files = Get-ChildItem -Path $BackupDir -File

if ($Files.Count -eq 0) {
    Write-Host "⚠️ No files found in $BackupDir" -ForegroundColor Yellow
    exit 0
}

Write-Host "Starting encryption..."
Write-Host ""

# Encrypt each file
foreach ($File in $Files) {
    $FileCount++
    $FileName = $File.Name
    $OutputPath = Join-Path $Destination "$FileName.enc"
    
    Write-Host "[$FileCount] Encrypting: $FileName"
    
    # Build command
    $PythonScript = Join-Path $CryptVaultPath "src\file_encryption_sandbox.py"
    $Arguments = @(
        $PythonScript,
        "encrypt",
        $File.FullName,
        "-k", $KeyName,
        "-p", $Password,
        "-o", $OutputPath
    )
    
    # Execute encryption
    $Process = Start-Process -FilePath "python" -ArgumentList $Arguments `
        -NoNewWindow -Wait -PassThru -RedirectStandardError "$env:TEMP\crypt_err.txt"
    
    if ($Process.ExitCode -eq 0) {
        $SuccessCount++
        Write-Host "    ✅ Success" -ForegroundColor Green
    } else {
        $FailCount++
        Write-Host "    ❌ Failed" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Backup Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Total files: $FileCount"
Write-Host "Successful: $SuccessCount" -ForegroundColor Green
Write-Host "Failed: $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })
Write-Host "Destination: $Destination"
Write-Host ""

if ($FailCount -eq 0) {
    Write-Host "✅ Backup completed successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️ Backup completed with errors" -ForegroundColor Yellow
    exit 1
}
