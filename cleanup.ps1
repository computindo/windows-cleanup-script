#Requires -RunAsAdministrator

# ============================================
# Windows Storage Cleanup Script
# github.com/computindo/windows-cleanup-script
# ============================================

$ErrorActionPreference = 'SilentlyContinue'

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "       Windows Storage Cleanup              " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# -----------------------------------------------
# Bagian 1 — Temp Files
# -----------------------------------------------
Write-Host "[1/6] Cleaning Temp Files..." -ForegroundColor Yellow

$tempPaths = @(
    $env:TEMP,
    "C:\Windows\Temp",
    "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Temp"
)

foreach ($path in $tempPaths) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Recurse -Force | Remove-Item -Recurse -Force
    }
}

Write-Host "  [OK] Temp Files cleaned." -ForegroundColor Green

# -----------------------------------------------
# Bagian 2 — Cache Explorer
# -----------------------------------------------
Write-Host "[2/6] Cleaning Explorer Cache..." -ForegroundColor Yellow

$explorerCachePaths = @(
    "$env:LocalAppData\Microsoft\Windows\Explorer\thumbcache_*.db",
    "$env:LocalAppData\IconCache.db",
    "C:\Windows\Prefetch\*",
    "$env:LocalAppData\CrashDumps\*"
)

foreach ($path in $explorerCachePaths) {
    Remove-Item -Path $path -Force -Recurse
}

# Flush DNS
ipconfig /flushdns | Out-Null

Write-Host "  [OK] Explorer Cache cleaned." -ForegroundColor Green

# -----------------------------------------------
# Bagian 3 — DISM Component Cleanup
# -----------------------------------------------
Write-Host "[3/6] Running DISM Cleanup..." -ForegroundColor Yellow
Write-Host "  (This may take a few minutes, please be patient...)" -ForegroundColor DarkGray

Dism /Online /Cleanup-Image /StartComponentCleanup /Quiet /NoRestart

Write-Host "  [OK] DISM Cleanup cleaned." -ForegroundColor Green

# -----------------------------------------------
# Bagian 4 — Disk Cleanup (cleanmgr)
# -----------------------------------------------
Write-Host "[4/6] Running Disk Cleanup..." -ForegroundColor Yellow

# Pastikan sageset sudah dikonfigurasi, kalau belum set dulu otomatis
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
$cleanupKeys = @(
    "Active Setup Temp Folders", "BranchCache", "Downloaded Program Files",
    "GameNewsFiles", "GameStatisticsFiles", "GameUpdateFiles",
    "Internet Cache Files", "Memory Dump Files", "Offline Pages Files",
    "Old ChkDsk Files", "Previous Installations", "Recycle Bin",
    "Service Pack Cleanup", "Setup Log Files", "System error memory dump files",
    "System error minidump files", "Temporary Files", "Temporary Setup Files",
    "Temporary Sync Files", "Thumbnail Cache", "Update Cleanup",
    "Upgrade Discarded Files", "User file versions", "Windows Defender",
    "Windows Error Reporting Archive Files", "Windows Error Reporting Queue Files",
    "Windows Error Reporting System Archive Files",
    "Windows Error Reporting System Queue Files", "Windows ESD installation files",
    "Windows Upgrade Log Files"
)

foreach ($key in $cleanupKeys) {
    $fullPath = "$regPath\$key"
    if (Test-Path $fullPath) {
        Set-ItemProperty -Path $fullPath -Name "StateFlags0001" -Value 2 -Type DWord
    }
}

Start-Process cleanmgr -ArgumentList "/sagerun:1" -Wait

Write-Host "  [OK] Disk Cleanup cleaned." -ForegroundColor Green

# -----------------------------------------------
# Bagian 5 — Browser Cache
# -----------------------------------------------
Write-Host "[5/6] Cleaning Browser Cache..." -ForegroundColor Yellow

$browserCachePaths = @(
    "$env:LocalAppData\Google\Chrome\User Data\Default\Cache\*",
    "$env:LocalAppData\Microsoft\Edge\User Data\Default\Cache\*",
    "$env:LocalAppData\BraveSoftware\Brave-Browser\User Data\Default\Cache\*"
)

foreach ($path in $browserCachePaths) {
    Remove-Item -Path $path -Force -Recurse
}

# Firefox — loop semua profile
$firefoxProfilesPath = "$env:AppData\Mozilla\Firefox\Profiles"
if (Test-Path $firefoxProfilesPath) {
    Get-ChildItem -Path $firefoxProfilesPath -Directory | ForEach-Object {
        Remove-Item -Path "$($_.FullName)\cache2\entries\*" -Force -Recurse
        Remove-Item -Path "$($_.FullName)\cache2\doomed\*"  -Force -Recurse
    }
}

Write-Host "  [OK] Browser Cache cleaned." -ForegroundColor Green

# -----------------------------------------------
# Bagian 6 — Windows.old
# -----------------------------------------------
Write-Host "[6/6] Checking Windows.old..." -ForegroundColor Yellow

if (Test-Path "C:\Windows.old") {
    Write-Host ""
    Write-Host "  Windows.old folder found, it's quite big!" -ForegroundColor Magenta
    $pilihan = Read-Host "  remove Windows.old? (Y/N)"

    if ($pilihan -eq 'Y' -or $pilihan -eq 'y') {
        Write-Host "  Deleting Windows.old..." -ForegroundColor Yellow
        Remove-Item -Path "C:\Windows.old" -Recurse -Force
        Write-Host "  [OK] Windows.old successfully deleted." -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] Windows.old skipped." -ForegroundColor DarkGray
    }
} else {
    Write-Host "  [SKIP] Windows.old not found." -ForegroundColor DarkGray
}

# ============================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "        Successfully Done!                 " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
