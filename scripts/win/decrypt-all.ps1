# ==============================================================================
# CryptVault - Decrypt All Script (PowerShell)
# ==============================================================================
#
# Decrypts all .encrypted files in a directory
#
# Usage:
#   .\scripts\windows\decrypt-all.ps1 -Directory <path> -Password <password>
#   .\scripts\windows\decrypt-all.ps1 -Directory <path> -KeyName <name> -Password <password>
#
# Examples:
#   .\scripts\windows\decrypt-all.ps1 -Directory sandbox -Password MyPassword123!
#   .\scripts\windows\decrypt-all.ps1 -Directory C:\encrypted-files -Password MyPassword123!
#   .\scripts\windows\decrypt-all.ps1 -Directory sandbox -KeyName backup-key -Password MyPassword123!
#
# ⚠️ WARNING: This will attempt to decrypt ALL .encrypted files
#
# ==============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Directory,
    
    [Parameter(Mandatory=$true)]
    [string]$Password,
    
    [Parameter(Mandatory=$false)]
    [string]$KeyName = ""
)

# Path to CryptVault
$CryptVaultPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "CryptVault - Decrypt All Files" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Directory: $Directory"
if ($KeyName) {
    Write-Host "Using key: $KeyName"
}
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

# Confirmation prompt
Write-Host "⚠️ WARNING: About to decrypt $($EncryptedFiles.Count) file(s)" -ForegroundColor Yellow
Write-Host ""
$Confirmation = Read-Host "Continue? (y/N)"

if ($Confirmation -ne 'y' -and $Confirmation -ne 'Y') {
    Write-Host "❌ Aborted by user" -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# Decrypt files
$FileCount = 0
$SuccessCount = 0
$FailCount = 0

foreach ($File in $EncryptedFiles) {
    $FileCount++
    $FileName = $File.Name
    
    Write-Host "[$FileCount/$($EncryptedFiles.Count)] Decrypting: $FileName"
    
    # Build command
    $PythonScript = Join-Path $CryptVaultPath "src\file_encryption_sandbox.py"
    $Arguments = @(
        $PythonScript,
        "decrypt",
        $File.FullName,
        "-p", $Password
    )
    
    # Add key-name if specified
    if ($KeyName) {
        $Arguments += @("-n", $KeyName)
    }
    
    # Execute decryption
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
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Decryption Summary" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Total files: $FileCount"
Write-Host "Successful: $SuccessCount" -ForegroundColor Green
Write-Host "Failed: $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($FailCount -eq 0) {
    Write-Host "✅ All files decrypted successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Decrypted files saved with .decrypted extension"
    exit 0
} else {
    Write-Host "⚠️ Some files failed to decrypt" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "  - Wrong password"
    Write-Host "  - Wrong key name"
    Write-Host "  - Corrupted encrypted file"
    Write-Host "  - Files encrypted with different passwords"
    exit 1
}
