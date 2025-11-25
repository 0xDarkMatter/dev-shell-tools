# dev-shell-tools task runner
# Run with: just <recipe>

# Default recipe - show available commands
default:
    @just --list

# Verify tool installation
verify:
    @echo "Running verification tests..."
    @if [ "$(uname)" = "Darwin" ] || [ "$(uname)" = "Linux" ]; then \
        ./tests/verify.sh; \
    else \
        powershell -ExecutionPolicy Bypass -File ./tests/verify.ps1; \
    fi

# Verify with benchmarks
benchmark:
    @echo "Running verification with benchmarks..."
    @if [ "$(uname)" = "Darwin" ] || [ "$(uname)" = "Linux" ]; then \
        ./tests/verify.sh --benchmark; \
    else \
        powershell -ExecutionPolicy Bypass -File ./tests/verify.ps1 -Benchmark; \
    fi

# Install tools (macOS)
install-mac:
    @echo "Installing tools via Homebrew..."
    cd macos && ./setup.sh

# Install tools (Windows) - run from PowerShell
install-win:
    @echo "Run from PowerShell: ./windows/setup.ps1"

# Quick check - just show installed vs missing
check:
    @echo "Checking tool availability..."
    @for cmd in rg fd bat eza delta zoxide fzf ast-grep jq yq sd just xh procs uv gh lazygit difft tokei broot; do \
        if command -v $$cmd >/dev/null 2>&1; then \
            echo "  [OK] $$cmd"; \
        else \
            echo "  [--] $$cmd"; \
        fi; \
    done
