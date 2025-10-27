# ==============================================================================
# CryptVault - Sandbox Cleanup Script (PowerShell)
# ==============================================================================
#
# Cleans up old encrypted/decrypted files from sandbox
#
# Usage:
#   .\scripts\windows\cleanup-sandbox.ps1 [-Days <int>] [-DryRun]
#
# Examples:
#   .\scripts\windows\cleanup-sandbox.ps1                # Delete files older than 30 days
#   .\scripts\windows\cleanup-sandbox.ps1 -Days 7        # Delete files older than 7 days
#   .\scripts\windows\cleanup-sandbox.ps1 -Days 30 -DryRun  # Preview without deleting
#
# ==============================================================================

param(
    [Parameter(Mandatory=$false)]
    [int]$Days = 30,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# Path to CryptVault
$CryptVaultPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$SandboxDir = Join-Path $CryptVaultPath "sandbox"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "CryptVault - Sandbox Cleanup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Sandbox: $SandboxDir"
Write-Host "Delete files older than: $Days days"
if ($DryRun) {
    Write-Host "Mode: DRY RUN (no files will be deleted)" -ForegroundColor Yellow
} else {
    Write-Host "Mode: LIVE (files will be permanently deleted)" -ForegroundColor Red
}
Write-Host "Date: $(Get-Date)"
Write-Host ""

# Check if sandbox exists
if (!(Test-Path $SandboxDir)) {
    Write-Host "❌ Error: Sandbox directory does not exist: $SandboxDir" -ForegroundColor Red
    exit 1
}

# Calculate cutoff date
$CutoffDate = (Get-Date).AddDays(-$Days)

Write-Host "Searching for files older than $Days days..."
Write-Host ""

# Find old files
$OldFiles = Get-ChildItem -Path $SandboxDir -File | Where-Object {
    ($_.Name -like "*.encrypted" -or $_.Name -like "*.decrypted") -and
    $_.LastWriteTime -lt $CutoffDate
}

if ($OldFiles.Count -eq 0) {
    Write-Host "✅ No files older than $Days days found" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($OldFiles.Count) file(s) to delete:"
Write-Host ""

# Calculate total size
$TotalSize = ($OldFiles | Measure-Object -Property Length -Sum).Sum

# List files
foreach ($File in $OldFiles) {
    $SizeKB = [math]::Round($File.Length / 1KB, 2)
    $Modified = $File.LastWriteTime.ToString("yyyy-MM-dd")
    
    Write-Host "  📄 $($File.Name)"
    Write-Host "     Size: $SizeKB KB | Modified: $Modified"
}

Write-Host ""
$TotalSizeMB = [math]::Round($TotalSize / 1MB, 2)
Write-Host "Total size to free: $TotalSizeMB MB"
Write-Host ""

# Dry run - exit here
if ($DryRun) {
    Write-Host "🔍 DRY RUN - No files were deleted" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To actually delete these files, run without -DryRun:" -ForegroundColor Yellow
    Write-Host "  .\scripts\windows\cleanup-sandbox.ps1 -Days $Days" -ForegroundColor Yellow
    exit 0
}

# Confirmation
Write-Host "⚠️ WARNING: These files will be permanently deleted!" -ForegroundColor Red
Write-Host ""
$Confirmation = Read-Host "Continue? (y/N)"

if ($Confirmation -ne 'y' -and $Confirmation -ne 'Y') {
    Write-Host "❌ Aborted by user" -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# Delete files
$DeletedCount = 0
$FailedCount = 0

Write-Host "Deleting files..."
foreach ($File in $OldFiles) {
    try {
        Remove-Item -Path $File.FullName -Force
        $DeletedCount++
        Write-Host "  ✅ Deleted: $($File.Name)" -ForegroundColor Green
    } catch {
        $FailedCount++
        Write-Host "  ❌ Failed: $($File.Name)" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Cleanup Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Files deleted: $DeletedCount" -ForegroundColor Green
Write-Host "Failed: $FailedCount" -ForegroundColor $(if ($FailedCount -eq 0) { "Green" } else { "Red" })
Write-Host "Space freed: $TotalSizeMB MB"
Write-Host ""

if ($FailedCount -eq 0) {
    Write-Host "✅ Cleanup completed successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️ Cleanup completed with errors" -ForegroundColor Yellow
    exit 1
}
