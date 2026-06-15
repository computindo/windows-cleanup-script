# Changelog

All notable changes to this project are documented here.

---

## [v3.3] - 2025-06-15

### Fixed
- **Deduplicated final report** — locked file entries that appeared dozens of times (one per file) are now collapsed into unique entries using `Select-Object -Unique`. Terminal output is now clean and readable.

---

## [v3.2] - 2025-06-14

### Fixed
- **Pipeline kill switch bug** — Previous versions used `-ErrorAction Stop` inside the delete pipeline, causing the entire operation to halt at the first locked file. All remaining files were silently skipped while the script still reported `[OK]`. Replaced with `-ErrorVariable` so the pipeline runs to completion regardless of individual file errors, then analyzes all errors afterward.

---

## [v3.1] - 2025-06-14

### Added
- **Windows version check** — Script now exits gracefully with a clear message if run on Windows versions below 10.
- **Recycle Bin fallback** — If `Clear-RecycleBin` fails, automatically falls back to Shell COM object method for broader compatibility.

### Fixed
- **Global ReparsePoint filter** — Symlinks and junction folders (e.g. `Application Data`) are now filtered globally inside `Remove-WithReport`, preventing false errors across all sections.
- **Correct exception classification** — `IOException` (file in use) and `UnauthorizedAccessException` (access restricted) are now correctly caught and reported as `[LOCKED]` (gray, normal) instead of `[FAILED]` (red, alarming).
- **Flexible Custom Mode input parser** — Input now accepts spaces, commas, or combinations (`1 4 5`, `1,4,5`, `1, 4, 5` all work).

### Changed
- Final report now has 3 distinct categories: `[!]` red for genuine errors, `[i]` gray for Windows-locked files (normal), and green for clean runs.

---

## [v3.0] - 2025-06-13

### Added
- **3-mode interactive main menu** — Clean All, Basic Clean, and Custom modes.
- **Custom Mode** — Users can select specific sections by number.
- **Basic Clean mode** — Runs only safe sections (Temp, WU Cache, Logs, WER) with no app shutdown required.
- **IconCache fix** — `explorer.exe` is temporarily stopped to unlock IconCache and thumbcache files, then restarted via `finally` block.

### Changed
- Full refactor to **function-based architecture** — each section is now an independent function.
- Section map (`$sectionMap`) enables dynamic section execution for Custom Mode.

---

## [v2.1] - 2025-06-13

### Added
- **`[PARTIAL]` section status** — Sections that complete with some errors now show yellow `[PARTIAL]` instead of green `[OK]`, eliminating the contradiction between section status and final report.
- **`$sectionHasError` flag** — Per-section error tracking variable.

### Fixed
- **Silent app kill** — `Stop-AppIfRunning` renamed to `Stop-AppWithConfirm` and now asks user permission before closing any running application, with a warning about potential data loss.
- **Dynamic browser profile paths** — Changed hardcoded `User Data\Default\Cache\*` to `User Data\*\Cache\*` wildcard to clean all Chrome/Edge/Brave profiles, not just the default one.

---

## [v2.0] - 2025-06-12

### Added
- Ported from `.bat` to `.ps1` (PowerShell).
- `try/catch` error handling per section — replaced global `$ErrorActionPreference = 'SilentlyContinue'`.
- `try/finally` for Windows Update service — guarantees `wuauserv` restarts even if script is interrupted.
- Final report with failed items summary.
- Auto-kill browser/app processes before cleaning their cache.
- 10 cleanup sections (up from 6 in v1).

### Removed
- `$ErrorActionPreference = 'SilentlyContinue'` global suppression — script is now fully transparent.

---

## [v1.0] - 2025-06-11

### Initial release
- Basic `.bat` script with 6 cleanup sections.
- Known issues: self-deletion when placed in `%TEMP%`, parser errors from comment characters, hardcoded paths.
