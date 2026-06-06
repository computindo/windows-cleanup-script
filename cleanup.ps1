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
# Section 1 — Temp Files
# -----------------------------------------------
Write-Host "[1/10] Cleaning Temp Files..." -ForegroundColor Yellow

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
# Section 2 — Explorer Cache
# -----------------------------------------------
Write-Host "[2/10] Cleaning Explorer Cache..." -ForegroundColor Yellow

$explorerCachePaths = @(
    "$env:LocalAppData\Microsoft\Windows\Explorer\thumbcache_*.db",
    "$env:LocalAppData\IconCache.db",
    "C:\Windows\Prefetch\*",
    "$env:LocalAppData\CrashDumps\*"
)

foreach ($path in $explorerCachePaths) {
    Remove-Item -Path $path -Force -Recurse
}

ipconfig /flushdns | Out-Null

Write-Host "  [OK] Explorer Cache cleaned." -ForegroundColor Green

# -----------------------------------------------
# Section 3 — DISM Component Cleanup (timeout: 60s)
# -----------------------------------------------
Write-Host "[3/10] Running DISM Cleanup..." -ForegroundColor Yellow
Write-Host "  (This may take a few minutes, please be patient...)" -ForegroundColor DarkGray

$dismJob = Start-Process -FilePath "Dism.exe" `
    -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup /Quiet /NoRestart" `
    -PassThru

$dismFinished = $dismJob.WaitForExit(60000)
if (-not $dismFinished) {
    $dismJob.Kill()
    Write-Host "  [SKIP] DISM timed out (60s), skipped." -ForegroundColor DarkGray
} else {
    Write-Host "  [OK] DISM Cleanup done." -ForegroundColor Green
}

# -----------------------------------------------
# Section 4 — Browser Cache
# -----------------------------------------------
Write-Host "[4/10] Cleaning Browser Cache..." -ForegroundColor Yellow

$browserCachePaths = @(
    "$env:LocalAppData\Google\Chrome\User Data\Default\Cache\*",
    "$env:LocalAppData\Microsoft\Edge\User Data\Default\Cache\*",
    "$env:LocalAppData\BraveSoftware\Brave-Browser\User Data\Default\Cache\*"
)

foreach ($path in $browserCachePaths) {
    Remove-Item -Path $path -Force -Recurse
}

$firefoxProfilesPath = "$env:AppData\Mozilla\Firefox\Profiles"
if (Test-Path $firefoxProfilesPath) {
    Get-ChildItem -Path $firefoxProfilesPath -Directory | ForEach-Object {
        Remove-Item -Path "$($_.FullName)\cache2\entries\*" -Force -Recurse
        Remove-Item -Path "$($_.FullName)\cache2\doomed\*"  -Force -Recurse
    }
}

Write-Host "  [OK] Browser Cache cleaned." -ForegroundColor Green

# -----------------------------------------------
# Section 5 — Windows Update Cache
# -----------------------------------------------
Write-Host "[5/10] Cleaning Windows Update Cache..." -ForegroundColor Yellow

Stop-Service -Name wuauserv -Force

$wuPaths = @(
    "C:\Windows\SoftwareDistribution\Download\*",
    "C:\Windows\SoftwareDistribution\DataStore\Logs\*"
)

foreach ($path in $wuPaths) {
    Remove-Item -Path $path -Recurse -Force
}

Start-Service -Name wuauserv

Write-Host "  [OK] Windows Update Cache cleaned." -ForegroundColor Green

# -----------------------------------------------
# Section 6 — Event Logs
# -----------------------------------------------
Write-Host "[6/10] Clearing Event Logs..." -ForegroundColor Yellow

$logs = @("Application", "System", "Security", "Setup")
foreach ($log in $logs) {
    wevtutil cl $log 2>$null
}

Write-Host "  [OK] Event Logs cleared." -ForegroundColor Green

# -----------------------------------------------
# Section 7 — Windows Error Reporting
# -----------------------------------------------
Write-Host "[7/10] Cleaning Windows Error Reporting..." -ForegroundColor Yellow

$werPaths = @(
    "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*",
    "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*",
    "$env:LocalAppData\Microsoft\Windows\WER\ReportArchive\*",
    "$env:LocalAppData\Microsoft\Windows\WER\ReportQueue\*"
)

foreach ($path in $werPaths) {
    Remove-Item -Path $path -Recurse -Force
}

Write-Host "  [OK] Windows Error Reporting cleaned." -ForegroundColor Green

# -----------------------------------------------
# Section 8 — App Cache (Teams, Spotify, Discord)
# -----------------------------------------------
Write-Host "[8/10] Cleaning App Cache..." -ForegroundColor Yellow

$appCachePaths = @(
    "$env:AppData\Microsoft\Teams\Cache\*",
    "$env:AppData\Microsoft\Teams\blob_storage\*",
    "$env:AppData\Microsoft\Teams\databases\*",
    "$env:AppData\Microsoft\Teams\GPUCache\*",
    "$env:AppData\Microsoft\Teams\IndexedDB\*",
    "$env:AppData\Microsoft\Teams\Local Storage\*",
    "$env:AppData\Microsoft\Teams\tmp\*",
    "$env:LocalAppData\Spotify\Data\*",
    "$env:AppData\discord\Cache\*",
    "$env:AppData\discord\Code Cache\*",
    "$env:AppData\discord\GPUCache\*"
)

foreach ($path in $appCachePaths) {
    Remove-Item -Path $path -Recurse -Force
}

Write-Host "  [OK] App Cache cleaned." -ForegroundColor Green

# -----------------------------------------------
# Section 9 — Recycle Bin (with confirmation)
# -----------------------------------------------
Write-Host "[9/10] Checking Recycle Bin..." -ForegroundColor Yellow
Write-Host ""

$shell = New-Object -ComObject Shell.Application
$recycleBin = $shell.Namespace(0xA)
$itemCount = ($recycleBin.Items() | Measure-Object).Count

if ($itemCount -gt 0) {
    Write-Host "  Recycle Bin contains $itemCount item(s)." -ForegroundColor Magenta
    $confirmRecycle = Read-Host "  Empty Recycle Bin? (Y/N)"
    if ($confirmRecycle -eq 'Y' -or $confirmRecycle -eq 'y') {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] Recycle Bin emptied." -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] Recycle Bin skipped." -ForegroundColor DarkGray
    }
} else {
    Write-Host "  [SKIP] Recycle Bin is already empty." -ForegroundColor DarkGray
}

# -----------------------------------------------
# Section 10 — Windows.old (with confirmation)
# -----------------------------------------------
Write-Host "[10/10] Checking Windows.old..." -ForegroundColor Yellow

if (Test-Path "C:\Windows.old") {
    Write-Host ""
    Write-Host "  Windows.old folder found — this can be several GB!" -ForegroundColor Magenta
    $confirmOld = Read-Host "  Delete Windows.old? (Y/N)"
    if ($confirmOld -eq 'Y' -or $confirmOld -eq 'y') {
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
Write-Host "           Cleanup Complete!                " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
