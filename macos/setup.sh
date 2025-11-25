#!/bin/bash
#
# Dev Shell Tools Setup (macOS)
# Installs modern CLI development tools via Homebrew
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

OPTIONAL=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --optional|-o) OPTIONAL=true ;;
        --help|-h)
            echo "Usage: $0 [--optional]"
            echo "  --optional, -o  Also install optional tools (starship, atuin, hyperfine)"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is required. Install it from https://brew.sh${NC}"
    echo 'Run: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

echo -e "\n${CYAN}=== Dev Shell Tools Setup (macOS) ===${NC}"
echo "Installing modern CLI tools for efficient development"

# Core tools
CORE_TOOLS=(
    "ripgrep:rg"
    "fd:fd"
    "bat:bat"
    "eza:eza"
    "git-delta:delta"
    "zoxide:zoxide"
    "fzf:fzf"
    "ast-grep:ast-grep"
    "jq:jq"
    "just:just"
    "httpie:http"
    "procs:procs"
    "uv:uv"
    "gh:gh"
    "lazygit:lazygit"
    "difftastic:difft"
    "sd:sd"
    "tokei:tokei"
    "yq:yq"
    "broot:br"
)

OPTIONAL_TOOLS=(
    "starship:starship"
    "atuin:atuin"
    "hyperfine:hyperfine"
)

install_tool() {
    local formula=$1
    local name=$2

    printf "  Installing %s..." "$name"

    if brew list "$formula" &>/dev/null; then
        echo -e " ${GREEN}already installed${NC}"
        return 0
    fi

    if brew install "$formula" &>/dev/null; then
        echo -e " ${GREEN}OK${NC}"
        return 0
    else
        echo -e " ${RED}FAILED${NC}"
        return 1
    fi
}

echo -e "\n${YELLOW}Installing core tools:${NC}"
failed=()

for tool in "${CORE_TOOLS[@]}"; do
    formula="${tool%%:*}"
    name="${tool##*:}"
    if ! install_tool "$formula" "$name"; then
        failed+=("$name")
    fi
done

if [ "$OPTIONAL" = true ]; then
    echo -e "\n${YELLOW}Installing optional tools:${NC}"
    for tool in "${OPTIONAL_TOOLS[@]}"; do
        formula="${tool%%:*}"
        name="${tool##*:}"
        if ! install_tool "$formula" "$name"; then
            failed+=("$name")
        fi
    done
fi

echo -e "\n${CYAN}=== Setup Complete ===${NC}"

if [ ${#failed[@]} -gt 0 ]; then
    echo -e "${RED}Failed to install: ${failed[*]}${NC}"
fi

# Detect shell
SHELL_NAME=$(basename "$SHELL")
SHELL_RC="$HOME/.${SHELL_NAME}rc"

echo -e "
${NC}Next steps:
1. Restart your shell or run: source $SHELL_RC

2. Configure git to use delta:
   git config --global core.pager delta
   git config --global interactive.diffFilter 'delta --color-only'

3. Initialize zoxide (add to $SHELL_RC):
   eval \"\$(zoxide init $SHELL_NAME)\"

4. Authenticate with GitHub:
   gh auth login

For full documentation, see ../README.md"
