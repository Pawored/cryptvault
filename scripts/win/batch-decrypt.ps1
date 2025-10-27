# ==============================================================================
# CryptVault - Batch Decrypt Script (PowerShell)
# ==============================================================================
#
# Selectively decrypt multiple files with pattern matching
#
# Usage:
#   .\scripts\windows\batch-decrypt.ps1 -Directory <path> -Pattern <pattern> -Password <password>
#
# Examples:
#   .\scripts\windows\batch-decrypt.ps1 -Directory sandbox -Pattern "*.pdf.encrypted" -Password MyPass123!
#   .\scripts\windows\batch-decrypt.ps1 -Directory C:\backup -Pattern "photo*.encrypted" -Password PhotoPass!
#   .\scripts\windows\batch-decrypt.ps1 -Directory sandbox -Pattern "*2024*.encrypted" -Password BackupPass!
#
# ==============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Directory,
    
    [Parameter(Mandatory=$true)]
    [string]$Pattern,
    
    [Parameter(Mandatory=$true)]
    [string]$Password
)

# Path to CryptVault
$CryptVaultPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "CryptVault - Batch Decrypt" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Directory: $Directory"
Write-Host "Pattern: $Pattern"
Write-Host "Date: $(Get-Date)"
Write-Host ""

# Check if directory exists
if (!(Test-Path $Directory)) {
    Write-Host "❌ Error: Directory does not exist: $Directory" -ForegroundColor Red
    exit 1
}

# Find matching files
$MatchedFiles = Get-ChildItem -Path $Directory -Filter $Pattern -File

if ($MatchedFiles.Count -eq 0) {
    Write-Host "⚠️ No files matching pattern '$Pattern' found in $Directory" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($MatchedFiles.Count) file(s) matching pattern"
Write-Host ""

# Show matched files
Write-Host "Files to decrypt:"
foreach ($File in $MatchedFiles) {
    Write-Host "  📄 $($File.Name)"
}
Write-Host ""

# Confirmation
$Confirmation = Read-Host "Decrypt these $($MatchedFiles.Count) file(s)? (y/N)"

if ($Confirmation -ne 'y' -and $Confirmation -ne 'Y') {
    Write-Host "❌ Aborted by user" -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# Decrypt files
$FileCount = 0
$SuccessCount = 0
$FailCount = 0

foreach ($File in $MatchedFiles) {
    $FileCount++
    $FileName = $File.Name
    
    Write-Host "[$FileCount/$($MatchedFiles.Count)] Decrypting: $FileName"
    
    # Build command
    $PythonScript = Join-Path $CryptVaultPath "src\file_encryption_sandbox.py"
    $Arguments = @(
        $PythonScript,
        "decrypt",
        $File.FullName,
        "-p", $Password
    )
    
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
Write-Host "Batch Decryption Summary" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Matched files: $FileCount"
Write-Host "Successful: $SuccessCount" -ForegroundColor Green
Write-Host "Failed: $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($FailCount -eq 0) {
    Write-Host "✅ All matched files decrypted successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️ Some files failed to decrypt" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "  - Wrong password"
    Write-Host "  - Corrupted encrypted file"
    Write-Host "  - Different passwords used for different files"
    exit 1
}
