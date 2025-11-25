#Requires -Version 5.1
<#
.SYNOPSIS
    Installs modern CLI development tools via winget.

.DESCRIPTION
    This script installs a curated set of CLI tools optimized for:
    - Fast file/code search (ripgrep, fd, ast-grep)
    - Better file viewing (bat, eza, delta)
    - Git workflows (lazygit, gh, difftastic)
    - Python development (uv)
    - Data processing (jq, sd)
    - Task automation (just, httpie, procs)

.PARAMETER Optional
    Also install optional tools (starship, atuin, hyperfine)

.EXAMPLE
    .\setup.ps1
    .\setup.ps1 -Optional
#>

param(
    [switch]$Optional
)

$ErrorActionPreference = "Stop"

# Check for winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget is required. Please install it from the Microsoft Store or Windows Package Manager."
    exit 1
}

Write-Host "`n=== Dev Shell Tools Setup (Windows) ===" -ForegroundColor Cyan
Write-Host "Installing modern CLI tools for efficient development`n"

# Core tools
$coreTools = @(
    @{ Id = "BurntSushi.ripgrep.MSVC"; Name = "ripgrep (rg)" },
    @{ Id = "sharkdp.fd"; Name = "fd" },
    @{ Id = "sharkdp.bat"; Name = "bat" },
    @{ Id = "eza-community.eza"; Name = "eza" },
    @{ Id = "dandavison.delta"; Name = "delta" },
    @{ Id = "ajeetdsouza.zoxide"; Name = "zoxide" },
    @{ Id = "junegunn.fzf"; Name = "fzf" },
    @{ Id = "ast-grep.ast-grep"; Name = "ast-grep" },
    @{ Id = "jqlang.jq"; Name = "jq" },
    @{ Id = "casey.just"; Name = "just" },
    @{ Id = "ducaale.xh"; Name = "xh (httpie-compatible)" },
    @{ Id = "dalance.procs"; Name = "procs" },
    @{ Id = "astral-sh.uv"; Name = "uv" },
    @{ Id = "GitHub.cli"; Name = "gh" },
    @{ Id = "JesseDuffield.lazygit"; Name = "lazygit" },
    @{ Id = "Wilfred.difftastic"; Name = "difftastic (difft)" },
    @{ Id = "chmln.sd"; Name = "sd" },
    @{ Id = "XAMPPRocky.Tokei"; Name = "tokei" },
    @{ Id = "mikefarah.yq"; Name = "yq" },
    @{ Id = "Dystroy.broot"; Name = "broot (br)" }
)

$optionalTools = @(
    @{ Id = "Starship.Starship"; Name = "starship" },
    @{ Id = "atuinsh.atuin"; Name = "atuin" },
    @{ Id = "sharkdp.hyperfine"; Name = "hyperfine" }
)

function Install-Tool {
    param($Tool)

    Write-Host "  Installing $($Tool.Name)..." -NoNewline

    $result = winget install --id $Tool.Id --accept-package-agreements --accept-source-agreements --silent 2>&1

    if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
        Write-Host " OK" -ForegroundColor Green
        return $true
    } else {
        Write-Host " FAILED" -ForegroundColor Red
        return $false
    }
}

Write-Host "Installing core tools:" -ForegroundColor Yellow
$failed = @()
foreach ($tool in $coreTools) {
    if (-not (Install-Tool $tool)) {
        $failed += $tool.Name
    }
}

if ($Optional) {
    Write-Host "`nInstalling optional tools:" -ForegroundColor Yellow
    foreach ($tool in $optionalTools) {
        if (-not (Install-Tool $tool)) {
            $failed += $tool.Name
        }
    }
}

Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan

if ($failed.Count -gt 0) {
    Write-Host "Failed to install: $($failed -join ', ')" -ForegroundColor Red
}

Write-Host @"

Next steps:
1. Restart your shell to pick up new PATH entries
2. Configure git to use delta:
   git config --global core.pager delta
   git config --global interactive.diffFilter "delta --color-only"

3. Initialize zoxide in your PowerShell profile:
   Add-Content `$PROFILE 'Invoke-Expression (& { (zoxide init powershell | Out-String) })'

4. Authenticate with GitHub:
   gh auth login

For full documentation, see ../README.md
"@ -ForegroundColor Gray
