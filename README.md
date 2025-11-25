# Dev Shell Tools

Modern CLI tools for efficient development workflows. Cross-platform support for Windows and macOS.

## Quick Install

### Windows (PowerShell)
```powershell
.\windows\setup.ps1

# Or import directly via winget
winget import -i windows\winget-dev-tools.json
```

### macOS (Homebrew)
```bash
./macos/setup.sh

# Or use Brewfile directly
brew bundle --file=macos/Brewfile
```

## Tool Categories

### Core Search & Navigation

| Tool | Command | Purpose | Why It Matters |
|------|---------|---------|----------------|
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `rg` | Fast regex search | 10-100x faster than grep, respects .gitignore |
| [fd](https://github.com/sharkdp/fd) | `fd` | Fast file finder | Simpler syntax than find, ignores hidden files by default |
| [fzf](https://github.com/junegunn/fzf) | `fzf` | Fuzzy finder | Pipe anything through it for interactive selection |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `z` | Smart cd | Learns your habits, `z proj` jumps to ~/Projects |
| [broot](https://github.com/Canop/broot) | `br` | Tree + nav + search | Explore large dirs without dumping full tree |
| [ast-grep](https://github.com/ast-grep/ast-grep) | `ast-grep` | Structural code search | AST-aware search/replace, finds semantic patterns |

### File Viewing & Diffing

| Tool | Command | Purpose | Why It Matters |
|------|---------|---------|----------------|
| [bat](https://github.com/sharkdp/bat) | `bat` | Better cat | Syntax highlighting, git integration, line numbers |
| [eza](https://github.com/eza-community/eza) | `eza` | Modern ls | Icons, git status, tree view built-in |
| [delta](https://github.com/dandavison/delta) | `delta` | Git diff viewer | Side-by-side diffs, syntax highlighting |
| [difftastic](https://github.com/Wilfred/difftastic) | `difft` | AST-aware diff | Shows semantic changes, not line noise |

### Git & Development

| Tool | Command | Purpose | Why It Matters |
|------|---------|---------|----------------|
| [lazygit](https://github.com/jesseduffield/lazygit) | `lazygit` | Git TUI | Visual staging, branch management, faster than CLI |
| [gh](https://cli.github.com/) | `gh` | GitHub CLI | PRs, issues, actions from terminal |
| [tokei](https://github.com/XAMPPRocky/tokei) | `tokei` | Code statistics | Fast LOC counting by language |

### Data Processing

| Tool | Command | Purpose | Why It Matters |
|------|---------|---------|----------------|
| [jq](https://github.com/jqlang/jq) | `jq` | JSON processor | Filter, transform, query JSON |
| [yq](https://github.com/mikefarah/yq) | `yq` | YAML/TOML processor | Same as jq for config files (K8s, CI, Docker Compose) |
| [sd](https://github.com/chmln/sd) | `sd` | Find & replace | Simpler than sed: `sd 'old' 'new' file` |

### Python Development

| Tool | Command | Purpose | Why It Matters |
|------|---------|---------|----------------|
| [uv](https://github.com/astral-sh/uv) | `uv` | Package manager | 10-100x faster than pip, handles venvs & Python versions |

### Task Running

| Tool | Command | Purpose | Why It Matters |
|------|---------|---------|----------------|
| [just](https://github.com/casey/just) | `just` | Command runner | Like make but simpler, cross-platform |
| [httpie](https://httpie.io/) | `http` | HTTP client | Human-friendly curl alternative |
| [procs](https://github.com/dalance/procs) | `procs` | Process viewer | Better ps with tree view, search |

## Optional Enhancements

| Tool | Command | Purpose |
|------|---------|---------|
| [starship](https://starship.rs/) | - | Cross-shell prompt |
| [atuin](https://atuin.sh/) | `atuin` | Shell history sync |
| [hyperfine](https://github.com/sharkdp/hyperfine) | `hyperfine` | Benchmarking |

Install with `--optional` flag (Windows) or `-o` flag (macOS).

## Token Efficiency for AI Coding Assistants

These tools reduce token usage when working with agentic coding tools (Claude Code, Codex CLI, Gemini CLI, Amp, Aider, etc.):

1. **ast-grep > grep** for structural queries - returns precise matches
2. **fd -e py | xargs ...** to scope operations narrowly
3. **jq filtering** before displaying JSON
4. **tokei** for quick codebase overview instead of manual counting
5. **difft** shows semantic changes, reducing noise in diffs

## Configuration

### Git with delta
```gitconfig
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true
    side-by-side = true
```

### Git with difftastic
```gitconfig
[diff]
    external = difft
```

### Zoxide initialization

**PowerShell** (add to `$PROFILE`):
```powershell
Invoke-Expression (& { (zoxide init powershell | Out-String) })
```

**Zsh** (add to `~/.zshrc`):
```bash
eval "$(zoxide init zsh)"
```

**Bash** (add to `~/.bashrc`):
```bash
eval "$(zoxide init bash)"
```

## Project Structure

```
dev-shell-tools/
├── README.md           # This file
├── AGENTS.md           # AI assistant guidelines
├── windows/
│   ├── setup.ps1       # PowerShell installer
│   └── winget-dev-tools.json
└── macos/
    ├── setup.sh        # Bash installer
    └── Brewfile        # Homebrew bundle
```

## License

MIT - Use freely for your own dev environment setup.
