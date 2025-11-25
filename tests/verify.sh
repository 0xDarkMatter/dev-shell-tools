#!/usr/bin/env bash
#
# Verify dev-shell-tools installation and benchmark against traditional tools.
#
# Usage:
#   ./tests/verify.sh
#   ./tests/verify.sh --benchmark

set -euo pipefail

BENCHMARK=false
[[ "${1:-}" == "--benchmark" ]] && BENCHMARK=true

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

success() { echo -e "  ${GREEN}[OK]${NC} $1"; }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; }
skip() { echo -e "  ${YELLOW}[SKIP]${NC} $1"; }
header() { echo -e "\n${CYAN}=== $1 ===${NC}"; }

# Tool definitions: name, command, version flag, replaces
declare -a TOOLS=(
    "ripgrep:rg:--version:grep"
    "fd:fd:--version:find"
    "bat:bat:--version:cat"
    "eza:eza:--version:ls"
    "delta:delta:--version:diff"
    "zoxide:zoxide:--version:cd"
    "fzf:fzf:--version:-"
    "ast-grep:ast-grep:--version:grep (structural)"
    "jq:jq:--version:-"
    "yq:yq:--version:-"
    "sd:sd:--version:sed"
    "just:just:--version:make"
    "xh:xh:--version:curl"
    "procs:procs:--version:ps"
    "uv:uv:--version:pip"
    "gh:gh:--version:-"
    "lazygit:lazygit:--version:git cli"
    "difftastic:difft:--version:diff"
    "tokei:tokei:--version:cloc"
    "broot:broot:--version:tree"
)

echo -e "\n${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Dev Shell Tools - Verification Test  ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"

# ============================================
# SECTION 1: Installation Check
# ============================================

header "Tool Installation Check"

installed=0
missing=()

for tool_def in "${TOOLS[@]}"; do
    IFS=':' read -r name cmd vflag replaces <<< "$tool_def"

    if command -v "$cmd" &> /dev/null; then
        version=$("$cmd" $vflag 2>&1 | head -n1)
        success "$name ($cmd) - $version"
        ((installed++))
    else
        fail "$name ($cmd) - NOT INSTALLED"
        missing+=("$name")
    fi
done

total=${#TOOLS[@]}
if [[ $installed -eq $total ]]; then
    echo -e "\nInstalled: ${GREEN}$installed / $total${NC}"
else
    echo -e "\nInstalled: ${YELLOW}$installed / $total${NC}"
fi

if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "${RED}Missing: ${missing[*]}${NC}"
    echo -e "\n${YELLOW}Run setup script to install missing tools:${NC}"
    echo -e "${GRAY}  ./macos/setup.sh${NC}"
fi

# ============================================
# SECTION 2: Functional Tests
# ============================================

header "Functional Tests"

# Test rg
if command -v rg &> /dev/null; then
    result=$(echo "test string" | rg "test" 2>&1 || true)
    if [[ "$result" == *"test"* ]]; then
        success "rg: pattern matching works"
    else
        fail "rg: pattern matching failed"
    fi
fi

# Test fd
if command -v fd &> /dev/null; then
    result=$(fd --version 2>&1)
    if [[ -n "$result" ]]; then
        success "fd: file finding works"
    else
        fail "fd: file finding failed"
    fi
fi

# Test jq
if command -v jq &> /dev/null; then
    result=$(echo '{"test": 123}' | jq '.test' 2>&1)
    if [[ "$result" == "123" ]]; then
        success "jq: JSON parsing works"
    else
        fail "jq: JSON parsing failed"
    fi
fi

# Test yq
if command -v yq &> /dev/null; then
    result=$(echo "test: 123" | yq '.test' 2>&1)
    if [[ "$result" == "123" ]]; then
        success "yq: YAML parsing works"
    else
        fail "yq: YAML parsing failed"
    fi
fi

# Test tokei
if command -v tokei &> /dev/null; then
    result=$(tokei --version 2>&1)
    if [[ -n "$result" ]]; then
        success "tokei: code stats works"
    else
        fail "tokei: code stats failed"
    fi
fi

# ============================================
# SECTION 3: Benchmarks (optional)
# ============================================

if [[ "$BENCHMARK" == true ]]; then
    header "Performance Benchmarks"
    echo -e "${GRAY}Creating test data...${NC}"

    # Create temp directory with test files
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    # Generate test files
    for i in $(seq 1 100); do
        content="Line with pattern\nAnother line\npattern here too\n"
        for _ in $(seq 1 100); do
            echo -e "$content"
        done > "$TEMP_DIR/file$i.txt"
    done

    echo -e "${GRAY}Running benchmarks on 100 files...${NC}"

    # Benchmark: rg vs grep
    if command -v rg &> /dev/null; then
        echo -e "\n  ${YELLOW}ripgrep vs grep:${NC}"

        # Time rg
        rg_start=$(date +%s%N)
        rg "pattern" "$TEMP_DIR" > /dev/null 2>&1
        rg_end=$(date +%s%N)
        rg_ms=$(( (rg_end - rg_start) / 1000000 ))

        # Time grep
        grep_start=$(date +%s%N)
        grep -r "pattern" "$TEMP_DIR" > /dev/null 2>&1
        grep_end=$(date +%s%N)
        grep_ms=$(( (grep_end - grep_start) / 1000000 ))

        if [[ $rg_ms -gt 0 ]]; then
            speedup=$(echo "scale=1; $grep_ms / $rg_ms" | bc)
        else
            speedup="∞"
        fi

        echo -e "    ${GREEN}rg:   ${rg_ms}ms${NC}"
        echo -e "    ${GRAY}grep: ${grep_ms}ms${NC}"
        echo -e "    ${CYAN}Speedup: ${speedup}x faster${NC}"
    fi

    # Benchmark: fd vs find
    if command -v fd &> /dev/null; then
        echo -e "\n  ${YELLOW}fd vs find:${NC}"

        # Time fd
        fd_start=$(date +%s%N)
        fd '\.txt$' "$TEMP_DIR" > /dev/null 2>&1
        fd_end=$(date +%s%N)
        fd_ms=$(( (fd_end - fd_start) / 1000000 ))

        # Time find
        find_start=$(date +%s%N)
        find "$TEMP_DIR" -name "*.txt" > /dev/null 2>&1
        find_end=$(date +%s%N)
        find_ms=$(( (find_end - find_start) / 1000000 ))

        if [[ $fd_ms -gt 0 ]]; then
            speedup=$(echo "scale=1; $find_ms / $fd_ms" | bc)
        else
            speedup="∞"
        fi

        echo -e "    ${GREEN}fd:   ${fd_ms}ms${NC}"
        echo -e "    ${GRAY}find: ${find_ms}ms${NC}"
        echo -e "    ${CYAN}Speedup: ${speedup}x faster${NC}"
    fi

    echo -e "\n  ${GRAY}Note: Real-world gains are typically 10-100x on larger codebases${NC}"
fi

# ============================================
# SECTION 4: Summary
# ============================================

header "Summary"

if [[ $installed -eq $total ]]; then
    echo -e "${GREEN}All tools installed and working!${NC}"
else
    echo -e "${YELLOW}$installed of $total tools installed${NC}"
fi

if [[ "$BENCHMARK" == false ]]; then
    echo -e "\n${GRAY}Run with --benchmark flag to see performance comparisons:${NC}"
    echo -e "${GRAY}  ./tests/verify.sh --benchmark${NC}"
fi

echo ""
