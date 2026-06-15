<div align="center">

```
               ██╗    ██╗██╗███╗   ██╗ ██████╗██╗     ███████╗ █████╗ ███╗   ██╗
               ██║    ██║██║████╗  ██║██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║
               ██║ █╗ ██║██║██╔██╗ ██║██║     ██║     █████╗  ███████║██╔██╗ ██║
               ██║███╗██║██║██║╚██╗██║██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║
               ╚███╔███╔╝██║██║ ╚████║╚██████╗███████╗███████╗██║  ██║██║ ╚████║
                ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝
```

**One-liner Windows storage cleanup. No install. No bloat. Just paste and run.**

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=flat-square&logo=powershell)](https://learn.microsoft.com/en-us/powershell/)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?style=flat-square&logo=windows)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Sections](https://img.shields.io/badge/Sections-10-orange?style=flat-square)](#-what-gets-cleaned)
[![Stars](https://img.shields.io/github/stars/computindo/windows-cleanup-script?style=flat-square)](https://github.com/computindo/windows-cleanup-script/stargazers)
[![Forks](https://img.shields.io/github/forks/computindo/windows-cleanup-script?style=flat-square)](https://github.com/computindo/windows-cleanup-script/network/members)

</div>

---

## ⚡ Quick Start

Open **PowerShell as Administrator** and paste this single command:

```powershell
irm https://computindo.github.io/windows-cleanup-script/cleanup.ps1 | iex
```

> **First time? Execution policy error?** Run this once, then retry:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

That's it. No download. No install. The script runs entirely in memory and cleans up after itself.

---

## 🧹 What Gets Cleaned

| # | Section | Available In | What It Removes |
|---|---------|:------------:|-----------------|
| 01 | **Temp Files** | All / Basic / Custom | User & system temp directories (`%TEMP%`, `C:\Windows\Temp`) |
| 02 | **Explorer Cache & IconCache** | All / Custom | Thumbnails, icon cache, prefetch files, DNS cache |
| 03 | **DISM Cleanup** | All / Custom | Windows component store bloat (WinSxS folder) |
| 04 | **Browser Cache** | All / Custom | Chrome, Edge, Brave, Firefox — all profiles |
| 05 | **Windows Update Cache** | All / Basic / Custom | `SoftwareDistribution\Download` — safe to delete anytime |
| 06 | **Event Logs** | All / Basic / Custom | Application, System, Security, Setup logs |
| 07 | **Windows Error Reporting** | All / Basic / Custom | WER report archives & queue |
| 08 | **App Cache** | All / Custom | Microsoft Teams, Spotify, Discord cache |
| 09 | **Recycle Bin** | All / Custom | Shows item count, asks Y/N before emptying |
| 10 | **Windows.old** | All / Custom | Previous Windows installation — asks Y/N before deleting |

---

## 🎛️ Cleaning Modes

When you run the script, an interactive menu appears:

```
============================================
     Windows Storage Cleanup v3.3
============================================

  Select cleaning mode:

  [1] Clean All    - Run all 10 sections
  [2] Basic Clean  - Safe sections only (Temp, WU Cache, Logs, WER)
  [3] Custom       - Choose which sections to run
  [X] Exit
```

**`[1] Clean All`** — Runs all 10 sections. Best for a full monthly cleanup.

**`[2] Basic Clean`** — Runs only sections 1, 5, 6, 7. No apps are closed, no prompts — fastest option for a quick daily run.

**`[3] Custom`** — Choose exactly which sections to run. Input numbers separated by space or comma:

```
Your selection: 1 4 5
# or: 1,4,5  or: 1, 4, 5  — all formats accepted
```

---

## 🖥️ Requirements

- Windows 10 or Windows 11
- PowerShell 5.1 or later *(pre-installed on all modern Windows — you already have it)*
- Administrator privileges *(required for system-level cleanup)*

---

## 📋 Step-by-Step Usage

**Step 1** — Press `Win`, type `powershell`, right-click the result → **Run as administrator** → click **Yes**

**Step 2** — Copy and paste this command, then press **Enter**:

```powershell
irm https://computindo.github.io/windows-cleanup-script/cleanup.ps1 | iex
```

**Step 3** — Select a cleaning mode from the menu (`1`, `2`, or `3`).

**Step 4** — Wait for the script to finish. When you see `Cleanup Complete!` — you're done.

> Sections **Browser Cache** and **App Cache** will ask permission before closing any running app. Sections **Recycle Bin** and **Windows.old** will ask Y/N before deleting anything.

---

## 📊 Expected Output

```
============================================
     Windows Storage Cleanup v3.3
============================================

  Select cleaning mode:

  [1] Clean All    - Run all 10 sections
  [2] Basic Clean  - Safe sections only (Temp, WU Cache, Logs, WER)
  [3] Custom       - Choose which sections to run
  [X] Exit

  Select option: 1

  [MODE] Clean All - running all sections...

[*] Cleaning Temp Files...
  [OK] Temp Files cleaned.
[*] Cleaning Explorer Cache & IconCache...
  [INFO] Temporarily stopping Explorer to unlock IconCache...
  [INFO] Explorer restarted.
  [OK] Explorer Cache & IconCache cleaned.
[*] Running DISM Cleanup...
  (This may take a few minutes, please be patient...)
  [OK] DISM Cleanup done.
[*] Cleaning Browser Cache...
  [!] Google Chrome is currently running.
      WARNING: Unsaved work in Google Chrome may be lost!
      Close Google Chrome and clean cache? (Y/N): y
      Google Chrome closed.
  [OK] Browser Cache cleaned.
[*] Cleaning Windows Update Cache...
  [INFO] Windows Update service stopped.
  [INFO] Windows Update service restarted.
  [OK] Windows Update Cache cleaned.
[*] Clearing Event Logs...
  [OK] Event Logs cleaned.
[*] Cleaning Windows Error Reporting...
  [OK] Windows Error Reporting cleaned.
[*] Cleaning App Cache...
  [OK] App Cache cleaned.
[*] Checking Recycle Bin...
  Recycle Bin contains 25 item(s).
  Empty Recycle Bin? (Y/N): y
  [OK] Recycle Bin emptied.
[*] Checking Windows.old...
  [SKIP] Windows.old not found.

============================================
           Cleanup Complete!
============================================

  [i] Files skipped (locked by Windows - this is normal):
      [LOCKED] Temp: C:\Users\...\Temp - file in use by system/process (normal)

  Note: These files are held by Windows and cannot be removed
        while the system is running. No action needed.
```

---

## 📋 Final Report Legend

| Status | Color | Meaning |
|--------|-------|---------|
| `[OK]` | 🟢 Green | Section completed with no errors |
| `[PARTIAL]` | 🟡 Yellow | Section completed, some files were skipped |
| `[SKIP]` | ⚫ Gray | Item not found or skipped by user — not an error |
| `[i] LOCKED` | ⚫ Gray | File held by Windows — normal, no action needed |
| `[!] FAILED` | 🔴 Red | Genuine error that needs attention |

---

## 🔒 Safety

- **No personal files touched** — Downloads, Documents, and Desktop folders are never accessed
- **Confirmation before closing apps** — If Chrome, Teams, or Discord is running, the script asks permission before closing it. Unsaved work is never lost silently
- **Confirmation for destructive actions** — Recycle Bin and Windows.old always ask Y/N before deletion
- **Honest error reporting** — Final report separates genuine errors (red) from Windows-locked files (gray). No false alarms
- **Failsafe service restart** — Windows Update service is guaranteed to restart even if the script is interrupted, via `finally` block
- **Global symlink protection** — Junction folders (e.g. `Application Data`) are automatically skipped to prevent unintended deletions
- **All browser profiles covered** — Uses wildcard paths (`User Data\*\Cache\*`) to clean all Chrome/Edge/Brave profiles, not just Default
- **Runs in memory** — no `.exe`, no installer, no leftover files after the script exits
- **No telemetry** — the script doesn't phone home or collect any data
- **Open source** — every line is readable in [`cleanup.ps1`](cleanup.ps1)

---

## 🔧 Troubleshooting

**`execution of scripts is disabled on this system`**

Run this once in PowerShell, then retry the main command:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Script runs but nothing happens / blank output**

Make sure you include `https://` in the URL. PowerShell's `irm` does not follow HTTP → HTTPS redirects automatically.

**DISM section takes a long time**

This is expected. DISM scans and cleans the Windows component store — it can take 5–15 minutes depending on your system. Let it finish.

**A section shows `[SKIP]`**

Not an error. It means that particular item wasn't found on your system — for example, no `Windows.old` folder, an empty Recycle Bin, or an app (Teams, Spotify, Discord) that isn't installed.

**Files appear in `[i] LOCKED` section**

Not an error. These files are actively held by Windows or a running process and cannot be deleted while the system is running. This is expected behavior — even professional tools like CCleaner cannot remove them.

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to add or change.

1. Fork the repo
2. Create your branch: `git checkout -b feature/new-section`
3. Commit your changes: `git commit -m 'Add: new cleanup section'`
4. Push to the branch: `git push origin feature/new-section`
5. Open a Pull Request

---

## 📄 License

MIT — see [`LICENSE`](LICENSE) for details.

---

<div align="center">
  <sub>Made by <a href="https://github.com/computindo">computindo</a> · Powered by PowerShell</sub>
</div>
