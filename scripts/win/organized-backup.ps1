# ==============================================================================
# CryptVault - Organized Backup Script (PowerShell)
# ==============================================================================
#
# Creates organized encrypted backups by category
#
# Usage:
#   .\scripts\windows\organized-backup.ps1
#
# Schedule with Task Scheduler:
#   - Monthly on 1st at 3:00 AM
#
# ==============================================================================

# -------------------------------
# CONFIGURATION - EDIT THESE
# -------------------------------

# Root directory for backups
$BackupRoot = "C:\backup\encrypted"

# Password for encryption (CHANGE THIS!)
$Password = "OrganizedBackup2024!"

# Date format
$Date = Get-Date -Format "yyyy-MM-dd"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Path to CryptVault
$CryptVaultPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# -------------------------------
# CATEGORIES - CUSTOMIZE THESE
# -------------------------------

# Define backup categories
$Categories = @{
    "documents" = @{
        "Path" = "$env:USERPROFILE\Documents"
        "Extensions" = @("*.pdf", "*.docx", "*.xlsx", "*.txt")
    }
    "photos" = @{
        "Path" = "$env:USERPROFILE\Pictures"
        "Extensions" = @("*.jpg", "*.jpeg", "*.png", "*.raw", "*.heic")
    }
    "videos" = @{
        "Path" = "$env:USERPROFILE\Videos"
        "Extensions" = @("*.mp4", "*.mov", "*.avi", "*.mkv")
    }
    "code" = @{
        "Path" = "$env:USERPROFILE\Projects"
        "Extensions" = @("*.py", "*.js", "*.java", "*.cpp", "*.zip")
    }
    "configs" = @{
        "Path" = "$env:APPDATA"
        "Extensions" = @("*.conf", "*.cfg", "*.json", "*.yaml", "*.yml")
    }
}

# -------------------------------
# SCRIPT START
# -------------------------------

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "CryptVault - Organized Backup" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date)" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# Statistics
$TotalCategories = 0
$TotalFiles = 0
$TotalSuccess = 0
$TotalFailed = 0

# Process each category
foreach ($CategoryName in $Categories.Keys) {
    $Category = $Categories[$CategoryName]
    $TotalCategories++
    
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "Category: $CategoryName" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow
    
    # Create category directory
    $CategoryDir = Join-Path $BackupRoot "$CategoryName\$Date"
    if (!(Test-Path $CategoryDir)) {
        New-Item -ItemType Directory -Path $CategoryDir -Force | Out-Null
    }
    
    Write-Host "Destination: $CategoryDir"
    Write-Host "Source: $($Category.Path)"
    Write-Host "Extensions: $($Category.Extensions -join ', ')"
    Write-Host ""
    
    # Check if source exists
    if (!(Test-Path $Category.Path)) {
        Write-Host "  ⚠️ Source directory does not exist: $($Category.Path)" -ForegroundColor Yellow
        Write-Host ""
        continue
    }
    
    # Statistics for this category
    $CategoryFiles = 0
    $CategorySuccess = 0
    $CategoryFailed = 0
    
    # Find and encrypt files
    foreach ($Extension in $Category.Extensions) {
        $Files = Get-ChildItem -Path $Category.Path -Filter $Extension -File -ErrorAction SilentlyContinue
        
        foreach ($File in $Files) {
            $CategoryFiles++
            $TotalFiles++
            
            $FileName = $File.Name
            $OutputPath = Join-Path $CategoryDir "$FileName.enc"
            
            Write-Host "[$CategoryFiles] Encrypting: $FileName"
            
            # Build command
            $PythonScript = Join-Path $CryptVaultPath "src\file_encryption_sandbox.py"
            $Arguments = @(
                $PythonScript,
                "encrypt",
                $File.FullName,
                "-p", $Password,
                "-o", $OutputPath
            )
            
            # Execute encryption
            $Process = Start-Process -FilePath "python" -ArgumentList $Arguments `
                -NoNewWindow -Wait -PassThru -RedirectStandardError "$env:TEMP\crypt_err.txt"
            
            if ($Process.ExitCode -eq 0) {
                $CategorySuccess++
                $TotalSuccess++
                Write-Host "    ✅ Success" -ForegroundColor Green
            } else {
                $CategoryFailed++
                $TotalFailed++
                Write-Host "    ❌ Failed" -ForegroundColor Red
            }
        }
    }
    
    # Category summary
    Write-Host ""
    Write-Host "Category Summary:"
    Write-Host "  Files: $CategoryFiles"
    Write-Host "  Success: $CategorySuccess" -ForegroundColor Green
    Write-Host "  Failed: $CategoryFailed" -ForegroundColor $(if ($CategoryFailed -eq 0) { "Green" } else { "Red" })
    Write-Host ""
    
    if ($CategoryFiles -eq 0) {
        Write-Host "  ⚠️ No files found in this category" -ForegroundColor Yellow
    } elseif ($CategoryFailed -eq 0) {
        Write-Host "  ✅ All files encrypted successfully" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️ Some files failed" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Overall summary
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Overall Backup Summary" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Categories processed: $TotalCategories"
Write-Host "Total files: $TotalFiles"
Write-Host "Successful: $TotalSuccess" -ForegroundColor Green
Write-Host "Failed: $TotalFailed" -ForegroundColor $(if ($TotalFailed -eq 0) { "Green" } else { "Red" })
Write-Host "Backup location: $BackupRoot"
Write-Host ""

# Create backup log
$LogFile = Join-Path $BackupRoot "backup-log-$Timestamp.txt"
$LogContent = @"
CryptVault Organized Backup Log
Date: $(Get-Date)

Categories: $TotalCategories
Files: $TotalFiles
Success: $TotalSuccess
Failed: $TotalFailed
"@

$LogContent | Out-File -FilePath $LogFile -Encoding UTF8

Write-Host "Log saved: $LogFile"
Write-Host ""

# Exit status
if ($TotalFailed -eq 0) {
    Write-Host "✅ Organized backup completed successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️ Backup completed with $TotalFailed error(s)" -ForegroundColor Yellow
    exit 1
}
