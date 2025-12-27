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

# Common winget installation paths to search
$WingetSearchPaths = @(
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages",
    "$env:LOCALAPPDATA\Microsoft\WinGet\Links",
    "$env:ProgramFiles",
    "${env:ProgramFiles(x86)}",
    "$env:LOCALAPPDATA\Programs",
    "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps",
    "$env:USERPROFILE\.cargo\bin"
)

# Find executable in common paths
function Find-ToolPath {
    param([string]$ExeName)

    # First try Get-Command (in PATH)
    $cmd = Get-Command $ExeName -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    # Search common winget paths
    foreach ($basePath in $WingetSearchPaths) {
        if (-not (Test-Path $basePath)) { continue }

        # Direct match
        $direct = Join-Path $basePath "$ExeName.exe"
        if (Test-Path $direct) { return $direct }

        # Search subdirectories (one level deep for speed)
        $found = Get-ChildItem -Path $basePath -Filter "$ExeName.exe" -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { return $found.FullName }
    }

    return $null
}

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
$foundPaths = @{}  # Track paths for tools not in PATH

foreach ($tool in $tools) {
    $toolPath = Find-ToolPath $tool.Cmd
    if ($toolPath) {
        $version = & $toolPath $tool.VersionFlag 2>&1 | Select-Object -First 1
        $inPath = Get-Command $tool.Cmd -ErrorAction SilentlyContinue
        if ($inPath) {
            Write-Success "$($tool.Name) ($($tool.Cmd)) - $version"
        } else {
            # Found but not in PATH
            Write-Success "$($tool.Name) ($($tool.Cmd)) - $version [NOT IN PATH]"
            $foundPaths[$tool.Cmd] = $toolPath
        }
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

if ($foundPaths.Count -gt 0) {
    Write-Host "`nTools found but not in PATH:" -ForegroundColor Yellow
    foreach ($tool in $foundPaths.Keys) {
        $dir = Split-Path $foundPaths[$tool] -Parent
        Write-Host "  $tool -> $dir" -ForegroundColor Gray
    }
    Write-Host "`nTo add to PATH, run:" -ForegroundColor Yellow
    $dirs = $foundPaths.Values | ForEach-Object { Split-Path $_ -Parent } | Sort-Object -Unique
    foreach ($dir in $dirs) {
        Write-Host "  `$env:Path += `";$dir`"" -ForegroundColor Gray
    }
}

# ============================================
# SECTION 2: Functional Tests
# ============================================

Write-Header "Functional Tests"

# Test rg
$rgPath = Find-ToolPath "rg"
if ($rgPath) {
    $result = "test string" | & $rgPath "test" 2>&1
    if ($result -match "test") { Write-Success "rg: pattern matching works" }
    else { Write-Fail "rg: pattern matching failed" }
}

# Test fd
$fdPath = Find-ToolPath "fd"
if ($fdPath) {
    $result = & $fdPath --version 2>&1
    if ($result) { Write-Success "fd: file finding works" }
    else { Write-Fail "fd: file finding failed" }
}

# Test jq
$jqPath = Find-ToolPath "jq"
if ($jqPath) {
    $result = '{"test": 123}' | & $jqPath '.test' 2>&1
    if ($result -eq "123") { Write-Success "jq: JSON parsing works" }
    else { Write-Fail "jq: JSON parsing failed" }
}

# Test yq
$yqPath = Find-ToolPath "yq"
if ($yqPath) {
    $result = "test: 123" | & $yqPath '.test' 2>&1
    if ($result -eq "123") { Write-Success "yq: YAML parsing works" }
    else { Write-Fail "yq: YAML parsing failed" }
}

# Test tokei
$tokeiPath = Find-ToolPath "tokei"
if ($tokeiPath) {
    $result = & $tokeiPath --version 2>&1
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
    $rgPath = Find-ToolPath "rg"
    if ($rgPath) {
        Write-Host "`n  ripgrep vs findstr:" -ForegroundColor Yellow

        $rgTime = Measure-Command { & $rgPath "pattern" $tempDir 2>&1 | Out-Null }
        $findstrTime = Measure-Command { Get-ChildItem $tempDir -File | ForEach-Object { findstr "pattern" $_.FullName } 2>&1 | Out-Null }

        $speedup = [math]::Round($findstrTime.TotalMilliseconds / $rgTime.TotalMilliseconds, 1)
        Write-Host "    rg:      $([math]::Round($rgTime.TotalMilliseconds, 1))ms" -ForegroundColor Green
        Write-Host "    findstr: $([math]::Round($findstrTime.TotalMilliseconds, 1))ms" -ForegroundColor Gray
        Write-Host "    Speedup: ${speedup}x faster" -ForegroundColor Cyan
    }

    # Benchmark: fd vs Get-ChildItem
    $fdPath = Find-ToolPath "fd"
    if ($fdPath) {
        Write-Host "`n  fd vs Get-ChildItem:" -ForegroundColor Yellow

        $fdTime = Measure-Command { & $fdPath "\.txt$" $tempDir 2>&1 | Out-Null }
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
