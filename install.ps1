# install.ps1 — Install Claude configuration into ~/.claude/
# Backs up any existing files before overwriting.

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$BackupDir = Join-Path $ClaudeDir ("backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))

# Ensure ~/.claude/ exists
if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
    Write-Host "Created $ClaudeDir"
}

# Back up files we're about to overwrite
$ExistingFiles = @()
if (Test-Path (Join-Path $ClaudeDir "CLAUDE.md")) {
    $ExistingFiles += "CLAUDE.md"
}
if (Test-Path (Join-Path $ClaudeDir "templates\wiki")) {
    $ExistingFiles += "templates\wiki"
}

if ($ExistingFiles.Count -gt 0) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
    foreach ($f in $ExistingFiles) {
        $src = Join-Path $ClaudeDir $f
        $dst = Join-Path $BackupDir $f
        $dstParent = Split-Path $dst -Parent
        if (-not (Test-Path $dstParent)) {
            New-Item -ItemType Directory -Path $dstParent -Force | Out-Null
        }
        Copy-Item -Path $src -Destination $dst -Recurse -Force
    }
    Write-Host "Backed up existing files to $BackupDir"
}

# Copy CLAUDE.md
Copy-Item -Path (Join-Path $RepoRoot "CLAUDE.md") -Destination $ClaudeDir -Force
Write-Host "Installed CLAUDE.md"

# Copy templates/
$TemplatesDst = Join-Path $ClaudeDir "templates"
if (-not (Test-Path $TemplatesDst)) {
    New-Item -ItemType Directory -Path $TemplatesDst | Out-Null
}
Copy-Item -Path (Join-Path $RepoRoot "templates\*") -Destination $TemplatesDst -Recurse -Force
Write-Host "Installed templates/"

Write-Host ""
Write-Host "Done. Open a new Claude Code session and run /memory to verify ~/.claude/CLAUDE.md is loaded as User memory."
