# ==============================================================================
# CryptVault - Encrypt by File Type (PowerShell)
# ==============================================================================
#
# Encrypts all files of a specific type in a directory
#
# Usage:
#   .\scripts\windows\encrypt-by-type.ps1 <extension> <password> [directory]
#
# Examples:
#   .\scripts\windows\encrypt-by-type.ps1 pdf MyPassword123!
#   .\scripts\windows\encrypt-by-type.ps1 pdf MyPassword123! C:\Users\Me\Documents
#   .\scripts\windows\encrypt-by-type.ps1 jpg PhotoPass2024! C:\Users\Me\Pictures
#
# ==============================================================================

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Extension,
    
    [Parameter(Mandatory=$true, Position=1)]
    [string]$Password,
    
    [Parameter(Mandatory=$false, Position=2)]
    [string]$Directory = "."
)

# Path to CryptVault
$CryptVaultPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "CryptVault - Encrypt by Type" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Extension: .$Extension"
Write-Host "Directory: $Directory"
Write-Host "Date: $(Get-Date)"
Write-Host ""

# Check if directory exists
if (!(Test-Path $Directory)) {
    Write-Host "❌ Error: Directory does not exist: $Directory" -ForegroundColor Red
    exit 1
}

# Find files with specified extension
Write-Host "Searching for *.$Extension files..."
Write-Host ""

$Files = Get-ChildItem -Path $Directory -Filter "*.$Extension" -File -Recurse

if ($Files.Count -eq 0) {
    Write-Host "⚠️ No .$Extension files found in $Directory" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($Files.Count) file(s)"
Write-Host ""

# Statistics
$FileCount = 0
$SuccessCount = 0
$FailCount = 0

# Encrypt each file
foreach ($File in $Files) {
    $FileCount++
    $FileName = $File.Name
    
    Write-Host "[$FileCount/$($Files.Count)] Encrypting: $FileName"
    
    # Build command
    $PythonScript = Join-Path $CryptVaultPath "src\file_encryption_sandbox.py"
    $Arguments = @(
        $PythonScript,
        "encrypt",
        $File.FullName,
        "-p", $Password
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
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Files found: $FileCount"
Write-Host "Successful: $SuccessCount" -ForegroundColor Green
Write-Host "Failed: $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($FailCount -eq 0) {
    Write-Host "✅ All .$Extension files encrypted successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️ Some files failed to encrypt" -ForegroundColor Yellow
    exit 1
}
