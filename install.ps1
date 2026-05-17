#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Install Cinit rule files into ~/.claude/ on Windows.

.DESCRIPTION
    Copies CLAUDE.md, templates/, hooks/, refs/, skills/, and the
    Windows-flavored settings.json into the user's ~/.claude/ directory.
    Existing files are backed up to ~/.claude/backups/install-<timestamp>/
    before being overwritten. Re-running is idempotent and safe.

    Does NOT touch settings.local.json — that file is per-machine and
    not owned by Cinit.

.NOTES
    Run from anywhere; the script uses its own location, not the
    current working directory, to find source files.
#>

[CmdletBinding()]
param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE '.claude'
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupRoot = Join-Path $ClaudeDir "backups\install-$Timestamp"

function Write-Step($msg) { Write-Host "  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  $msg" -ForegroundColor Yellow }

Write-Host "`nCinit install (Windows)" -ForegroundColor White
Write-Host "  Source: $ScriptDir"
Write-Host "  Target: $ClaudeDir"
if ($DryRun) { Write-Warn "DRY RUN — no files will be written." }
Write-Host ""

# Ensure target directory exists
if (-not (Test-Path $ClaudeDir)) {
    Write-Step "Creating $ClaudeDir"
    if (-not $DryRun) { New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null }
}

# Items to install: source path (relative to repo root) -> target path (relative to ~/.claude/)
$Items = @(
    @{ Src = 'CLAUDE.md';                            Dst = 'CLAUDE.md';                            Kind = 'file' },
    @{ Src = 'templates';                            Dst = 'templates';                            Kind = 'dir'  },
    @{ Src = 'hooks';                                Dst = 'hooks';                                Kind = 'dir'  },
    @{ Src = 'refs';                                 Dst = 'refs';                                 Kind = 'dir'  },
    @{ Src = 'skills';                               Dst = 'skills';                               Kind = 'dir'  },
    @{ Src = 'settings\settings.windows.json';       Dst = 'settings.json';                        Kind = 'file' }
)

$BackedUp = @()

foreach ($item in $Items) {
    $srcPath = Join-Path $ScriptDir $item.Src
    $dstPath = Join-Path $ClaudeDir $item.Dst

    if (-not (Test-Path $srcPath)) {
        Write-Warn "Source missing, skipping: $($item.Src)"
        continue
    }

    # Back up existing target before overwriting
    if (Test-Path $dstPath) {
        $backupPath = Join-Path $BackupRoot $item.Dst
        Write-Step "Backing up existing $($item.Dst) -> $backupPath"
        if (-not $DryRun) {
            $backupParent = Split-Path -Parent $backupPath
            if (-not (Test-Path $backupParent)) { New-Item -ItemType Directory -Path $backupParent -Force | Out-Null }
            if ($item.Kind -eq 'dir') {
                Copy-Item -Path $dstPath -Destination $backupPath -Recurse -Force
            } else {
                Copy-Item -Path $dstPath -Destination $backupPath -Force
            }
        }
        $BackedUp += $item.Dst
    }

    Write-Step "Installing $($item.Src) -> $($item.Dst)"
    if (-not $DryRun) {
        if ($item.Kind -eq 'dir') {
            # Remove target first so deletions in source propagate
            if (Test-Path $dstPath) { Remove-Item -Path $dstPath -Recurse -Force }
            Copy-Item -Path $srcPath -Destination $dstPath -Recurse -Force
        } else {
            $dstParent = Split-Path -Parent $dstPath
            if (-not (Test-Path $dstParent)) { New-Item -ItemType Directory -Path $dstParent -Force | Out-Null }
            Copy-Item -Path $srcPath -Destination $dstPath -Force
        }
    }
}

Write-Host ""
Write-Ok "Install complete."
if ($BackedUp.Count -gt 0) {
    Write-Host "  Backed up $($BackedUp.Count) existing items to:" -ForegroundColor Gray
    Write-Host "    $BackupRoot" -ForegroundColor Gray
}
Write-Host "  Next: restart Claude Code so new top-level skills directories are watched." -ForegroundColor Gray
Write-Host ""
