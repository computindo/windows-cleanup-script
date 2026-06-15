#Requires -RunAsAdministrator

# ============================================
# Windows Storage Cleanup Script v3.3
# github.com/computindo/windows-cleanup-script
# ============================================

$failedItems     = @()
$lockedItems     = @()
$sectionHasError = $false

# ============================================
# WINDOWS VERSION CHECK (minimum Windows 10)
# ============================================
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-Host ""
    Write-Host "  [!] Unsupported Windows version detected." -ForegroundColor Red
    Write-Host "      This script requires Windows 10 or later." -ForegroundColor Red
    Write-Host "      Your version: $($osVersion.ToString())" -ForegroundColor DarkGray
    Write-Host ""
    exit
}

# ============================================
# HELPER FUNCTIONS
# ============================================

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ██╗    ██╗██╗███╗   ██╗ ██████╗██╗     ███████╗ █████╗ ███╗   ██╗" -ForegroundColor Cyan
    Write-Host "  ██║    ██║██║████╗  ██║██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║" -ForegroundColor Cyan
    Write-Host "  ██║ █╗ ██║██║██╔██╗ ██║██║     ██║     █████╗  ███████║██╔██╗ ██║" -ForegroundColor Cyan
    Write-Host "  ██║███╗██║██║██║≕██╗██║██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║" -ForegroundColor Cyan
    Write-Host "  ╚███╔███╔╝██║██║ ╚████║╚██████╗███████╗███████╗██║  ██║██║ ╚████║" -ForegroundColor Cyan
    Write-Host "   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Windows Storage Cleanup v3.3                    by computindo" -ForegroundColor DarkGray
    Write-Host ""
}

# ENGINE UTAMA v3.2 - bulk delete + ErrorVariable
# Tidak pakai -ErrorAction Stop jadi pipeline TIDAK berhenti di tengah jalan
# Semua error dikumpulkan dulu, baru dianalisis setelah selesai
function Remove-WithReport {
    param([string]$Path, [string]$Label)

    if (-not (Test-Path $Path)) { return }

    $deleteErrors = @()

    # Bulk delete dengan -ErrorVariable: pipeline terus jalan meski ada error
    # -ErrorAction SilentlyContinue: tidak berhenti, tidak print error ke console
    # -ErrorVariable: kumpulkan semua error ke $deleteErrors untuk dianalisis
    Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Attributes -notmatch 'ReparsePoint' } |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable +deleteErrors

    # Analisis error setelah pipeline selesai penuh
    foreach ($err in $deleteErrors) {
        $exception = $err.Exception

        if ($exception -is [System.IO.IOException]) {
            # File dikunci proses lain - NORMAL
            $script:lockedItems += "[LOCKED] $Label - file in use by system/process (normal)"

        } elseif ($exception -is [System.UnauthorizedAccessException]) {
            # Access restricted - juga sering NORMAL untuk file sistem
            $script:lockedItems += "[LOCKED] $Label - access restricted by Windows (normal)"

        } else {
            # Error genuine yang perlu perhatian
            $script:sectionHasError = $true
            $script:failedItems += "[FAILED] $Label - $($exception.GetType().Name): $($exception.Message)"
        }
    }
}

function Write-SectionStatus {
    param([string]$SectionName)
    if ($script:sectionHasError) {
        Write-Host "  [PARTIAL] $SectionName - completed with some errors." -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] $SectionName cleaned." -ForegroundColor Green
    }
    $script:sectionHasError = $false
}

function Stop-AppWithConfirm {
    param([string[]]$ProcessNames, [string]$AppLabel)
    $runningProcs = @()
    foreach ($name in $ProcessNames) {
        $found = Get-Process -Name $name -ErrorAction SilentlyContinue
        if ($found) { $runningProcs += $found }
    }
    if ($runningProcs.Count -eq 0) { return $true }

    Write-Host ""
    Write-Host "  [!] $AppLabel is currently running." -ForegroundColor Magenta
    Write-Host "      WARNING: Unsaved work in $AppLabel may be lost!" -ForegroundColor Yellow
    $confirm = Read-Host "      Close $AppLabel and clean cache? (Y/N)"
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        $runningProcs | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 800
        Write-Host "      $AppLabel closed." -ForegroundColor DarkGray
        return $true
    } else {
        Write-Host "      [SKIP] $AppLabel cache skipped by user." -ForegroundColor DarkGray
        return $false
    }
}

function Write-FinalReport {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "           Cleanup Complete!                " -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan

    # Kategori 1: FAILED - genuine error (merah)
    if ($script:failedItems.Count -gt 0) {
        Write-Host ""
        Write-Host "  [!] Errors that need attention:" -ForegroundColor Red
        $uniqueFailed = $script:failedItems | Select-Object -Unique
        foreach ($item in $uniqueFailed) {
            Write-Host "      $item" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "  Tip: Try closing related apps and run the script again." -ForegroundColor DarkGray
    }

    # Kategori 2: LOCKED - file dikunci OS, normal (abu-abu)
    if ($script:lockedItems.Count -gt 0) {
        Write-Host ""
        Write-Host "  [i] Files skipped (locked by Windows - this is normal):" -ForegroundColor DarkGray
        $uniqueLocked = $script:lockedItems | Select-Object -Unique
        foreach ($item in $uniqueLocked) {
            Write-Host "      $item" -ForegroundColor DarkGray
        }
        Write-Host ""
        Write-Host "  Note: These files are held by Windows and cannot be removed" -ForegroundColor DarkGray
        Write-Host "        while the system is running. No action needed." -ForegroundColor DarkGray
    }

    # Kategori 3: semua bersih
    if ($script:failedItems.Count -eq 0 -and $script:lockedItems.Count -eq 0) {
        Write-Host "  All sections completed with no errors." -ForegroundColor Green
    }

    Write-Host ""
}

# ============================================
# SECTION FUNCTIONS
# ============================================

function Clean-TempFiles {
    Write-Host "[*] Cleaning Temp Files..." -ForegroundColor Yellow
    $script:sectionHasError = $false
    $tempPaths = @(
        $env:TEMP,
        "C:\Windows\Temp",
        "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Temp"
    )
    foreach ($path in $tempPaths) {
        Remove-WithReport -Path "$path\*" -Label "Temp: $path"
    }
    Write-SectionStatus "Temp Files"
}

function Clean-ExplorerCache {
    Write-Host "[*] Cleaning Explorer Cache & IconCache..." -ForegroundColor Yellow
    $script:sectionHasError = $false
    Write-Host "  [INFO] Temporarily stopping Explorer to unlock IconCache..." -ForegroundColor DarkGray
    try {
        Stop-Process -Name "explorer" -Force -ErrorAction Stop
        Start-Sleep -Seconds 2

        Remove-WithReport "$env:LocalAppData\Microsoft\Windows\Explorer\thumbcache_*.db" "Thumbcache"
        Remove-WithReport "$env:LocalAppData\IconCache.db"                                "IconCache"
        Remove-WithReport "C:\Windows\Prefetch\*"                                         "Prefetch"
        Remove-WithReport "$env:LocalAppData\CrashDumps\*"                               "CrashDumps"
        ipconfig /flushdns | Out-Null
    } catch {
        $script:sectionHasError = $true
        $script:failedItems += "[FAILED] Explorer Cache - $($_.Exception.Message)"
    } finally {
        Start-Process "explorer.exe"
        Start-Sleep -Seconds 2
        Write-Host "  [INFO] Explorer restarted." -ForegroundColor DarkGray
    }
    Write-SectionStatus "Explorer Cache & IconCache"
}

function Clean-DISM {
    Write-Host "[*] Running DISM Cleanup..." -ForegroundColor Yellow
    Write-Host "  (This may take a few minutes, please be patient...)" -ForegroundColor DarkGray
    try {
        $dismJob = Start-Process -FilePath "Dism.exe" `
            -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup /Quiet /NoRestart" `
            -PassThru -ErrorAction Stop
        $dismFinished = $dismJob.WaitForExit(60000)
        if (-not $dismFinished) {
            $dismJob.Kill()
            Write-Host "  [SKIP] DISM timed out (60s), skipped." -ForegroundColor DarkGray
        } else {
            Write-Host "  [OK] DISM Cleanup done." -ForegroundColor Green
        }
    } catch {
        Write-Host "  [ERROR] DISM - $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Clean-BrowserCache {
    Write-Host "[*] Cleaning Browser Cache..." -ForegroundColor Yellow
    $script:sectionHasError = $false

    if (Stop-AppWithConfirm @("chrome") "Google Chrome") {
        Remove-WithReport "$env:LocalAppData\Google\Chrome\User Data\*\Cache\*"      "Chrome Cache"
        Remove-WithReport "$env:LocalAppData\Google\Chrome\User Data\*\Code Cache\*" "Chrome Code Cache"
    }
    if (Stop-AppWithConfirm @("msedge") "Microsoft Edge") {
        Remove-WithReport "$env:LocalAppData\Microsoft\Edge\User Data\*\Cache\*"      "Edge Cache"
        Remove-WithReport "$env:LocalAppData\Microsoft\Edge\User Data\*\Code Cache\*" "Edge Code Cache"
    }
    if (Stop-AppWithConfirm @("brave") "Brave Browser") {
        Remove-WithReport "$env:LocalAppData\BraveSoftware\Brave-Browser\User Data\*\Cache\*" "Brave Cache"
    }
    if (Stop-AppWithConfirm @("firefox") "Mozilla Firefox") {
        $ffPath = "$env:AppData\Mozilla\Firefox\Profiles"
        if (Test-Path $ffPath) {
            Get-ChildItem -Path $ffPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                Remove-WithReport "$($_.FullName)\cache2\entries\*" "Firefox cache2 entries"
                Remove-WithReport "$($_.FullName)\cache2\doomed\*"  "Firefox cache2 doomed"
            }
        }
    }
    Write-SectionStatus "Browser Cache"
}

function Clean-WindowsUpdate {
    Write-Host "[*] Cleaning Windows Update Cache..." -ForegroundColor Yellow
    $script:sectionHasError = $false
    try {
        Stop-Service -Name wuauserv -Force -ErrorAction Stop
        Write-Host "  [INFO] Windows Update service stopped." -ForegroundColor DarkGray
        Remove-WithReport "C:\Windows\SoftwareDistribution\Download\*"       "WU Download"
        Remove-WithReport "C:\Windows\SoftwareDistribution\DataStore\Logs\*" "WU DataStore Logs"
    } catch {
        Write-Host "  [ERROR] Windows Update Cache - $($_.Exception.Message)" -ForegroundColor Red
        $script:sectionHasError = $true
        $script:failedItems += "[FAILED] Windows Update service - could not be stopped"
    } finally {
        $svc = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -ne 'Running') {
            Start-Service -Name wuauserv -ErrorAction SilentlyContinue
            Write-Host "  [INFO] Windows Update service restarted." -ForegroundColor DarkGray
        }
    }
    Write-SectionStatus "Windows Update Cache"
}

function Clean-EventLogs {
    Write-Host "[*] Clearing Event Logs..." -ForegroundColor Yellow
    $script:sectionHasError = $false
    $logs = @("Application", "System", "Security", "Setup")
    foreach ($log in $logs) {
        try {
            wevtutil cl $log 2>$null
        } catch {
            $script:sectionHasError = $true
            $script:failedItems += "[FAILED] Event Log '$log' - $($_.Exception.Message)"
        }
    }
    Write-SectionStatus "Event Logs"
}

function Clean-WER {
    Write-Host "[*] Cleaning Windows Error Reporting..." -ForegroundColor Yellow
    $script:sectionHasError = $false
    $werPaths = @(
        "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*",
        "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*",
        "$env:LocalAppData\Microsoft\Windows\WER\ReportArchive\*",
        "$env:LocalAppData\Microsoft\Windows\WER\ReportQueue\*"
    )
    foreach ($path in $werPaths) { Remove-WithReport $path "WER" }
    Write-SectionStatus "Windows Error Reporting"
}

function Clean-AppCache {
    Write-Host "[*] Cleaning App Cache..." -ForegroundColor Yellow
    $script:sectionHasError = $false

    if (Stop-AppWithConfirm @("Teams", "ms-teams") "Microsoft Teams") {
        $teamsPaths = @(
            "$env:AppData\Microsoft\Teams\Cache\*",
            "$env:AppData\Microsoft\Teams\blob_storage\*",
            "$env:AppData\Microsoft\Teams\databases\*",
            "$env:AppData\Microsoft\Teams\GPUCache\*",
            "$env:AppData\Microsoft\Teams\IndexedDB\*",
            "$env:AppData\Microsoft\Teams\Local Storage\*",
            "$env:AppData\Microsoft\Teams\tmp\*"
        )
        foreach ($path in $teamsPaths) { Remove-WithReport $path "Teams" }
    }
    if (Stop-AppWithConfirm @("Spotify") "Spotify") {
        Remove-WithReport "$env:LocalAppData\Spotify\Data\*" "Spotify"
    }
    if (Stop-AppWithConfirm @("Discord") "Discord") {
        $discordPaths = @(
            "$env:AppData\discord\Cache\*",
            "$env:AppData\discord\Code Cache\*",
            "$env:AppData\discord\GPUCache\*"
        )
        foreach ($path in $discordPaths) { Remove-WithReport $path "Discord" }
    }
    Write-SectionStatus "App Cache"
}

function Clean-RecycleBin {
    Write-Host "[*] Checking Recycle Bin..." -ForegroundColor Yellow
    Write-Host ""
    try {
        $shell      = New-Object -ComObject Shell.Application
        $recycleBin = $shell.Namespace(0xA)
        $itemCount  = ($recycleBin.Items() | Measure-Object).Count
        if ($itemCount -gt 0) {
            Write-Host "  Recycle Bin contains $itemCount item(s)." -ForegroundColor Magenta
            $confirm = Read-Host "  Empty Recycle Bin? (Y/N)"
            if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                try {
                    Clear-RecycleBin -Force -ErrorAction Stop
                } catch {
                    $recycleBin.Items() | ForEach-Object { $_.InvokeVerb("delete") }
                }
                Write-Host "  [OK] Recycle Bin emptied." -ForegroundColor Green
            } else {
                Write-Host "  [SKIP] Recycle Bin skipped." -ForegroundColor DarkGray
            }
        } else {
            Write-Host "  [SKIP] Recycle Bin is already empty." -ForegroundColor DarkGray
        }
    } catch {
        Write-Host "  [ERROR] Recycle Bin - $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Clean-WindowsOld {
    Write-Host "[*] Checking Windows.old..." -ForegroundColor Yellow
    try {
        if (Test-Path "C:\Windows.old") {
            Write-Host ""
            Write-Host "  Windows.old found - this can be several GB!" -ForegroundColor Magenta
            $confirm = Read-Host "  Delete Windows.old? (Y/N)"
            if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                Write-Host "  Deleting Windows.old..." -ForegroundColor Yellow
                Remove-Item -Path "C:\Windows.old" -Recurse -Force -ErrorAction Stop
                Write-Host "  [OK] Windows.old successfully deleted." -ForegroundColor Green
            } else {
                Write-Host "  [SKIP] Windows.old skipped." -ForegroundColor DarkGray
            }
        } else {
            Write-Host "  [SKIP] Windows.old not found." -ForegroundColor DarkGray
        }
    } catch {
        Write-Host "  [ERROR] Windows.old - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ============================================
# SECTION MAP
# ============================================
$sectionMap = @{
    1  = @{ Name = "Temp Files";                        Func = { Clean-TempFiles     } }
    2  = @{ Name = "Explorer Cache & IconCache";        Func = { Clean-ExplorerCache  } }
    3  = @{ Name = "DISM Cleanup";                      Func = { Clean-DISM           } }
    4  = @{ Name = "Browser Cache";                     Func = { Clean-BrowserCache   } }
    5  = @{ Name = "Windows Update Cache";              Func = { Clean-WindowsUpdate  } }
    6  = @{ Name = "Event Logs";                        Func = { Clean-EventLogs      } }
    7  = @{ Name = "Windows Error Reporting";           Func = { Clean-WER            } }
    8  = @{ Name = "App Cache (Teams/Spotify/Discord)"; Func = { Clean-AppCache       } }
    9  = @{ Name = "Recycle Bin";                       Func = { Clean-RecycleBin     } }
    10 = @{ Name = "Windows.old";                       Func = { Clean-WindowsOld     } }
}

$basicSections = @(1, 5, 6, 7)

# ============================================
# MAIN MENU
# ============================================
Write-Header

Write-Host "  Select cleaning mode:" -ForegroundColor White
Write-Host ""
Write-Host "  [1] Clean All    - Run all 10 sections" -ForegroundColor Cyan
Write-Host "  [2] Basic Clean  - Safe sections only (Temp, WU Cache, Logs, WER)" -ForegroundColor Cyan
Write-Host "  [3] Custom       - Choose which sections to run" -ForegroundColor Cyan
Write-Host "  [X] Exit" -ForegroundColor Cyan
Write-Host ""

$mode = Read-Host "  Select option"

switch ($mode.ToUpper()) {

    "1" {
        Write-Host ""
        Write-Host "  [MODE] Clean All - running all sections..." -ForegroundColor Green
        Write-Host ""
        Clean-TempFiles
        Clean-ExplorerCache
        Clean-DISM
        Clean-BrowserCache
        Clean-WindowsUpdate
        Clean-EventLogs
        Clean-WER
        Clean-AppCache
        Clean-RecycleBin
        Clean-WindowsOld
        Write-FinalReport
    }

    "2" {
        Write-Host ""
        Write-Host "  [MODE] Basic Clean - safe sections only..." -ForegroundColor Green
        Write-Host ""
        foreach ($num in $basicSections) {
            & $sectionMap[$num].Func
        }
        Write-FinalReport
    }

    "3" {
        Write-Host ""
        Write-Host "  [MODE] Custom - available sections:" -ForegroundColor Green
        Write-Host ""
        foreach ($num in 1..10) {
            Write-Host ("  [{0,2}] {1}" -f $num, $sectionMap[$num].Name) -ForegroundColor Cyan
        }
        Write-Host ""
        Write-Host "  Enter numbers separated by space or comma." -ForegroundColor DarkGray
        Write-Host "  Example: 1 4 5  or  1,4,5  or  1, 4, 5" -ForegroundColor DarkGray
        Write-Host ""
        $rawInput = Read-Host "  Your selection"

        $selected = $rawInput -split '[\s,]+' |
                    Where-Object { $_ -match '^\d+$' } |
                    ForEach-Object { [int]$_ } |
                    Where-Object { $sectionMap.ContainsKey($_) } |
                    Sort-Object -Unique

        if ($selected.Count -eq 0) {
            Write-Host ""
            Write-Host "  [!] No valid sections selected. Please run the script again." -ForegroundColor Red
            Write-Host ""
            exit
        }

        Write-Host ""
        Write-Host "  Selected sections:" -ForegroundColor White
        foreach ($num in $selected) {
            Write-Host ("    [{0}] {1}" -f $num, $sectionMap[$num].Name) -ForegroundColor Cyan
        }
        Write-Host ""
        $confirm = Read-Host "  Proceed? (Y/N)"
        if ($confirm -ne 'Y' -and $confirm -ne 'y') {
            Write-Host "  Cancelled." -ForegroundColor DarkGray
            Write-Host ""
            exit
        }

        Write-Host ""
        foreach ($num in $selected) {
            & $sectionMap[$num].Func
        }
        Write-FinalReport
    }

    "X" {
        Write-Host ""
        Write-Host "  Exiting. No changes made." -ForegroundColor DarkGray
        Write-Host ""
        exit
    }

    default {
        Write-Host ""
        Write-Host "  [!] Invalid option. Please run the script again." -ForegroundColor Red
        Write-Host ""
        exit
    }
}
