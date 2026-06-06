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
[![Sections](https://img.shields.io/badge/Sections-11-orange?style=flat-square)](#-what-gets-cleaned)
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

| # | Section | Mode | What It Removes |
|---|---------|:----:|-----------------|
| 01 | **Temp Files** | `AUTO` | User & system temp directories (`%TEMP%`, `C:\Windows\Temp`) |
| 02 | **Explorer Cache** | `AUTO` | Thumbnails, icon cache, prefetch files, DNS cache |
| 03 | **DISM Cleanup** | `AUTO` | Windows component store bloat (WinSxS folder) |
| 04 | **Disk Cleanup** | `AUTO` | Full `cleanmgr` sweep via registry automation |
| 05 | **Browser Cache** | `AUTO` | Chrome, Edge, Brave, Firefox cache folders |
| 06 | **Windows Update Cache** | `AUTO` | `SoftwareDistribution\Download` — safe to delete anytime |
| 07 | **Event Logs** | `AUTO` | Application, System, Security, Setup logs |
| 08 | **Windows Error Reporting** | `AUTO` | WER report archives & queue |
| 09 | **App Cache** | `AUTO` | Microsoft Teams, Spotify, Discord cache |
| 10 | **Recycle Bin** | `CONFIRM` | Shows item count before asking Y/N |
| 11 | **Windows.old** | `CONFIRM` | Previous Windows installation — asks before deleting |

**`AUTO`** = runs silently, no input needed  
**`CONFIRM`** = shows what will be deleted and asks Y/N first

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

**Step 3** — Wait for the script to finish. It will show progress for each of the 11 sections. When you see `Cleanup Complete!` — you're done.

> **Sections 10 and 11** (Recycle Bin and Windows.old) will pause and ask `Y/N` before deleting anything.

---

## 📊 Expected Output

```
============================================
       Windows Storage Cleanup
============================================

[1/11] Cleaning Temp Files...
  [OK] Temp Files cleaned.
[2/11] Cleaning Explorer Cache...
  [OK] Explorer Cache cleaned.
[3/11] Running DISM Cleanup...
  (This may take a few minutes, please be patient...)
  [OK] DISM Cleanup done.
[4/11] Running Disk Cleanup...
  [OK] Disk Cleanup done.
[5/11] Cleaning Browser Cache...
  [OK] Browser Cache cleaned.
[6/11] Cleaning Windows Update Cache...
  [OK] Windows Update Cache cleaned.
[7/11] Clearing Event Logs...
  [OK] Event Logs cleared.
[8/11] Cleaning Windows Error Reporting...
  [OK] Windows Error Reporting cleaned.
[9/11] Cleaning App Cache...
  [OK] App Cache cleaned.
[10/11] Checking Recycle Bin...
  Recycle Bin contains 43 item(s).
  Empty Recycle Bin? (Y/N): y
  [OK] Recycle Bin emptied.
[11/11] Checking Windows.old...
  [SKIP] Windows.old not found.

============================================
           Cleanup Complete!
============================================
```

> `[SKIP]` is not an error — it just means that item wasn't found on your system (e.g. no `Windows.old`, empty Recycle Bin, or app not installed).

---

## 🔒 Safety

- **No personal files touched** — Downloads, Documents, and Desktop folders are never accessed
- **Confirmation required** for anything potentially large or irreversible (Recycle Bin, Windows.old)
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
