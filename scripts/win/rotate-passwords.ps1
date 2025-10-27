# ==============================================================================
# CryptVault - Password Rotation Script (PowerShell)
# ==============================================================================
#
# Rotates passwords by re-encrypting files with a new password
#
# Usage:
#   .\scripts\windows\rotate-passwords.ps1 -Directory <path> -OldPassword <old> -NewPassword <new>
#
# Examples:
#   .\scripts\windows\rotate-passwords.ps1 -Directory sandbox -OldPassword OldPass2023! -NewPassword NewPass2024!
#   .\scripts\windows\rotate-passwords.ps1 -Directory C:\encrypted-files -OldPassword OldPass! -NewPassword NewPass!
#
# ⚠️ WARNING: This will decrypt and re-encrypt all files
#
# ==============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Directory,
    
    [Parameter(Mandatory=$true)]
    [string]$OldPassword,
    
    [Parameter(Mandatory=$true)]
    [string]$NewPassword
)

# Path to CryptVault
$CryptVaultPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "CryptVault - Password Rotation" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Directory: $Directory"
Write-Host "Date: $(Get-Date)"
Write-Host ""

# Check if directory exists
if (!(Test-Path $Directory)) {
    Write-Host "❌ Error: Directory does not exist: $Directory" -ForegroundColor Red
    exit 1
}

# Find encrypted files
$EncryptedFiles = Get-ChildItem -Path $Directory -Filter "*.encrypted" -File

if ($EncryptedFiles.Count -eq 0) {
    Write-Host "⚠️ No .encrypted files found in $Directory" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($EncryptedFiles.Count) encrypted file(s)"
Write-Host ""

# Warning
Write-Host "⚠️ WARNING: Password Rotation Process" -ForegroundColor Red
Write-Host ""
Write-Host "This will:"
Write-Host "  1. Decrypt all files with old password"
Write-Host "  2. Re-encrypt with new password"
Write-Host "  3. Replace old encrypted files"
Write-Host ""
Write-Host "Make sure you have backups before proceeding!" -ForegroundColor Yellow
Write-Host ""

$Confirmation = Read-Host "Continue? (y/N)"

if ($Confirmation -ne 'y' -and $Confirmation -ne 'Y') {
    Write-Host "❌ Aborted by user" -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# Create temporary directory
$TempDir = Join-Path $env:TEMP "cryptvault_rotate_$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

Write-Host "Using temporary directory: $TempDir"
Write-Host ""

# Statistics
$TotalFiles = $EncryptedFiles.Count
$SuccessCount = 0
$FailCount = 0

# Process each file
foreach ($File in $EncryptedFiles) {
    $FileName = $File.Name
    $BaseFileName = $FileName -replace '\.encrypted$', ''
    
    Write-Host "Processing: $FileName"
    
    # Step 1: Decrypt with old password
    Write-Host "  1/3 Decrypting with old password..."
    
    $PythonScript = Join-Path $CryptVaultPath "src\file_encryption_sandbox.py"
    $TempFile = Join-Path $TempDir $BaseFileName
    
    $Arguments = @(
        $PythonScript,
        "decrypt",
        $File.FullName,
        "-p", $OldPassword,
        "-o", $TempFile
    )
    
    $Process = Start-Process -FilePath "python" -ArgumentList $Arguments `
        -NoNewWindow -Wait -PassThru -RedirectStandardError "$env:TEMP\crypt_err.txt"
    
    if ($Process.ExitCode -ne 0) {
        Write-Host "  ❌ Failed to decrypt (wrong old password?)" -ForegroundColor Red
        $FailCount++
        continue
    }
    
    # Step 2: Re-encrypt with new password
    Write-Host "  2/3 Re-encrypting with new password..."
    
    $TempEncrypted = Join-Path $TempDir "$BaseFileName.encrypted"
    
    $Arguments = @(
        $PythonScript,
        "encrypt",
        $TempFile,
        "-p", $NewPassword,
        "-o", $TempEncrypted
    )
    
    $Process = Start-Process -FilePath "python" -ArgumentList $Arguments `
        -NoNewWindow -Wait -PassThru -RedirectStandardError "$env:TEMP\crypt_err.txt"
    
    if ($Process.ExitCode -ne 0) {
        Write-Host "  ❌ Failed to re-encrypt" -ForegroundColor Red
        $FailCount++
        Remove-Item -Path $TempFile -Force -ErrorAction SilentlyContinue
        continue
    }
    
    # Step 3: Replace old encrypted file
    Write-Host "  3/3 Replacing old encrypted file..."
    
    try {
        Move-Item -Path $TempEncrypted -Destination $File.FullName -Force
        Write-Host "  ✅ Success - password rotated" -ForegroundColor Green
        $SuccessCount++
    } catch {
        Write-Host "  ❌ Failed to replace file" -ForegroundColor Red
        $FailCount++
    }
    
    # Cleanup temp files
    Remove-Item -Path $TempFile -Force -ErrorAction SilentlyContinue
    
    Write-Host ""
}

# Cleanup temp directory
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

# Summary
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Password Rotation Summary" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Total files: $TotalFiles"
Write-Host "Successful: $SuccessCount" -ForegroundColor Green
Write-Host "Failed: $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($FailCount -eq 0) {
    Write-Host "✅ All passwords rotated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Test decryption with new password"
    Write-Host "  2. Update your password manager"
    Write-Host "  3. Delete old backups (after verifying)"
    exit 0
} else {
    Write-Host "⚠️ Some files failed password rotation" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Failed files still use old password."
    Write-Host "Successfully rotated files use new password."
    Write-Host ""
    Write-Host "Recommendation: Review failed files and try again"
    exit 1
}
