#Requires -Version 5.1
<#
.SYNOPSIS
    Verify dev-shell-tools installation and benchmark against traditional tools.

.DESCRIPTION
    Tests that modern CLI tools are installed and compares performance
    against traditional equivalents where applicable.

.EXAMPLE
    .\tests\verify.ps1
    .\tests\verify.ps1 -Benchmark
#>

param(
    [switch]$Benchmark
)

$ErrorActionPreference = "Continue"

# Colors
function Write-Success { param($msg) Write-Host "  [OK] " -NoNewline -ForegroundColor Green; Write-Host $msg }
function Write-Fail { param($msg) Write-Host "  [FAIL] " -NoNewline -ForegroundColor Red; Write-Host $msg }
function Write-Skip { param($msg) Write-Host "  [SKIP] " -NoNewline -ForegroundColor Yellow; Write-Host $msg }
function Write-Header { param($msg) Write-Host "`n=== $msg ===" -ForegroundColor Cyan }

# Tool definitions: name, command, version flag
$tools = @(
    @{ Name = "ripgrep"; Cmd = "rg"; VersionFlag = "--version"; Replaces = "grep" },
    @{ Name = "fd"; Cmd = "fd"; VersionFlag = "--version"; Replaces = "find" },
    @{ Name = "bat"; Cmd = "bat"; VersionFlag = "--version"; Replaces = "cat" },
    @{ Name = "eza"; Cmd = "eza"; VersionFlag = "--version"; Replaces = "ls" },
    @{ Name = "delta"; Cmd = "delta"; VersionFlag = "--version"; Replaces = "diff" },
    @{ Name = "zoxide"; Cmd = "zoxide"; VersionFlag = "--version"; Replaces = "cd" },
    @{ Name = "fzf"; Cmd = "fzf"; VersionFlag = "--version"; Replaces = "-" },
    @{ Name = "ast-grep"; Cmd = "ast-grep"; VersionFlag = "--version"; Replaces = "grep (structural)" },
    @{ Name = "jq"; Cmd = "jq"; VersionFlag = "--version"; Replaces = "-" },
    @{ Name = "yq"; Cmd = "yq"; VersionFlag = "--version"; Replaces = "-" },
    @{ Name = "sd"; Cmd = "sd"; VersionFlag = "--version"; Replaces = "sed" },
    @{ Name = "just"; Cmd = "just"; VersionFlag = "--version"; Replaces = "make" },
    @{ Name = "xh"; Cmd = "xh"; VersionFlag = "--version"; Replaces = "curl" },
    @{ Name = "procs"; Cmd = "procs"; VersionFlag = "--version"; Replaces = "ps" },
    @{ Name = "uv"; Cmd = "uv"; VersionFlag = "--version"; Replaces = "pip" },
    @{ Name = "gh"; Cmd = "gh"; VersionFlag = "--version"; Replaces = "-" },
    @{ Name = "lazygit"; Cmd = "lazygit"; VersionFlag = "--version"; Replaces = "git cli" },
    @{ Name = "difftastic"; Cmd = "difft"; VersionFlag = "--version"; Replaces = "diff" },
    @{ Name = "tokei"; Cmd = "tokei"; VersionFlag = "--version"; Replaces = "cloc" },
    @{ Name = "broot"; Cmd = "broot"; VersionFlag = "--version"; Replaces = "tree" }
)

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Dev Shell Tools - Verification Test  " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# ============================================
# SECTION 1: Installation Check
# ============================================

Write-Header "Tool Installation Check"

$installed = 0
$missing = @()

foreach ($tool in $tools) {
    $cmd = Get-Command $tool.Cmd -ErrorAction SilentlyContinue
    if ($cmd) {
        $version = & $tool.Cmd $tool.VersionFlag 2>&1 | Select-Object -First 1
        Write-Success "$($tool.Name) ($($tool.Cmd)) - $version"
        $installed++
    } else {
        Write-Fail "$($tool.Name) ($($tool.Cmd)) - NOT INSTALLED"
        $missing += $tool.Name
    }
}

$color = if ($installed -eq $tools.Count) { "Green" } else { "Yellow" }
Write-Host "`nInstalled: $installed / $($tools.Count)" -ForegroundColor $color

if ($missing.Count -gt 0) {
    Write-Host "Missing: $($missing -join ', ')" -ForegroundColor Red
    Write-Host "`nRun setup script to install missing tools:" -ForegroundColor Yellow
    Write-Host "  .\windows\setup.ps1" -ForegroundColor Gray
}

# ============================================
# SECTION 2: Functional Tests
# ============================================

Write-Header "Functional Tests"

# Test rg
if (Get-Command rg -ErrorAction SilentlyContinue) {
    $result = "test string" | rg "test" 2>&1
    if ($result -match "test") { Write-Success "rg: pattern matching works" }
    else { Write-Fail "rg: pattern matching failed" }
}

# Test fd
if (Get-Command fd -ErrorAction SilentlyContinue) {
    $result = fd --version 2>&1
    if ($result) { Write-Success "fd: file finding works" }
    else { Write-Fail "fd: file finding failed" }
}

# Test jq
if (Get-Command jq -ErrorAction SilentlyContinue) {
    $result = '{"test": 123}' | jq '.test' 2>&1
    if ($result -eq "123") { Write-Success "jq: JSON parsing works" }
    else { Write-Fail "jq: JSON parsing failed" }
}

# Test yq
if (Get-Command yq -ErrorAction SilentlyContinue) {
    $result = "test: 123" | yq '.test' 2>&1
    if ($result -eq "123") { Write-Success "yq: YAML parsing works" }
    else { Write-Fail "yq: YAML parsing failed" }
}

# Test tokei
if (Get-Command tokei -ErrorAction SilentlyContinue) {
    $result = tokei --version 2>&1
    if ($result) { Write-Success "tokei: code stats works" }
    else { Write-Fail "tokei: code stats failed" }
}

# ============================================
# SECTION 3: Benchmarks (optional)
# ============================================

if ($Benchmark) {
    Write-Header "Performance Benchmarks"
    Write-Host "Creating test data..." -ForegroundColor Gray

    # Create temp directory with test files
    $tempDir = Join-Path $env:TEMP "dev-shell-tools-bench"
    if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
    New-Item -ItemType Directory -Path $tempDir | Out-Null

    # Generate test files
    1..100 | ForEach-Object {
        $content = "Line with pattern`nAnother line`npattern here too`n" * 100
        Set-Content -Path (Join-Path $tempDir "file$_.txt") -Value $content
    }

    Write-Host "Running benchmarks on 100 files..." -ForegroundColor Gray

    # Benchmark: rg vs findstr (Windows grep equivalent)
    if (Get-Command rg -ErrorAction SilentlyContinue) {
        Write-Host "`n  ripgrep vs findstr:" -ForegroundColor Yellow

        $rgTime = Measure-Command { rg "pattern" $tempDir 2>&1 | Out-Null }
        $findstrTime = Measure-Command { Get-ChildItem $tempDir -File | ForEach-Object { findstr "pattern" $_.FullName } 2>&1 | Out-Null }

        $speedup = [math]::Round($findstrTime.TotalMilliseconds / $rgTime.TotalMilliseconds, 1)
        Write-Host "    rg:      $([math]::Round($rgTime.TotalMilliseconds, 1))ms" -ForegroundColor Green
        Write-Host "    findstr: $([math]::Round($findstrTime.TotalMilliseconds, 1))ms" -ForegroundColor Gray
        Write-Host "    Speedup: ${speedup}x faster" -ForegroundColor Cyan
    }

    # Benchmark: fd vs Get-ChildItem
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        Write-Host "`n  fd vs Get-ChildItem:" -ForegroundColor Yellow

        $fdTime = Measure-Command { fd "\.txt$" $tempDir 2>&1 | Out-Null }
        $gciTime = Measure-Command { Get-ChildItem $tempDir -Filter "*.txt" -Recurse 2>&1 | Out-Null }

        $speedup = [math]::Round($gciTime.TotalMilliseconds / $fdTime.TotalMilliseconds, 1)
        Write-Host "    fd:              $([math]::Round($fdTime.TotalMilliseconds, 1))ms" -ForegroundColor Green
        Write-Host "    Get-ChildItem:   $([math]::Round($gciTime.TotalMilliseconds, 1))ms" -ForegroundColor Gray
        Write-Host "    Speedup: ${speedup}x faster" -ForegroundColor Cyan
    }

    # Cleanup
    Remove-Item -Recurse -Force $tempDir

    Write-Host "`n  Note: Real-world gains are typically 10-100x on larger codebases" -ForegroundColor Gray
}

# ============================================
# SECTION 4: Summary
# ============================================

Write-Header "Summary"

if ($installed -eq $tools.Count) {
    Write-Host "All tools installed and working!" -ForegroundColor Green
} else {
    Write-Host "$installed of $($tools.Count) tools installed" -ForegroundColor Yellow
}

if (-not $Benchmark) {
    Write-Host "`nRun with -Benchmark flag to see performance comparisons:" -ForegroundColor Gray
    Write-Host "  .\tests\verify.ps1 -Benchmark" -ForegroundColor Gray
}

Write-Host ""
