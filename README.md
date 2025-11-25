# Dev Shell Tools

A curated collection of modern CLI tools that replace slow, verbose Unix defaults with fast, ergonomic alternatives. Built for developers who value speed and for AI coding assistants that benefit from concise, structured output.

## Why These Tools?

### Performance
Most tools in this collection are written in **Rust** or **Go**, making them 10-100x faster than traditional Unix utilities:

| Traditional | Modern | Speedup | Why |
|-------------|--------|---------|-----|
| `grep -r` | `rg` | 10-100x | Parallelized, respects .gitignore, smart defaults |
| `find` | `fd` | 5-10x | Parallelized, intuitive syntax, ignores hidden files |
| `cat` | `bat` | ~1x | Same speed, but adds syntax highlighting |
| `pip install` | `uv` | 10-100x | Rust-based resolver, parallel downloads, caching |

### Token Efficiency for AI Assistants
When working with AI coding tools (Claude Code, Codex CLI, Gemini CLI, Amp, Aider), output verbosity directly impacts:
- **Context window usage** - verbose output wastes tokens
- **Response accuracy** - noise obscures signal
- **Speed** - more tokens = slower responses

These tools produce **structured, minimal output** by default:

```bash
# Bad: grep dumps everything, no structure
grep -r "function" .
# 500+ lines of noisy output

# Good: rg respects .gitignore, groups by file
rg "function" --type js
# Clean, grouped output - 10x fewer lines

# Bad: find lists everything including .git, node_modules
find . -name "*.py"
# Hundreds of irrelevant results

# Good: fd ignores junk by default
fd -e py
# Only relevant files

# Bad: tree dumps entire directory structure
tree
# 1000+ lines for any real project

# Good: broot lets you explore interactively
br
# Navigate without dumping everything

# Bad: diff shows line-by-line noise
diff old.js new.js
# Hard to see what actually changed

# Good: difft shows semantic changes
difft old.js new.js
# Shows actual code structure changes
```

### Ergonomics
Simpler syntax, sane defaults, and better UX:

```bash
# Find & replace
sed 's/old/new/g' file          # Cryptic
sd 'old' 'new' file             # Intuitive

# Directory navigation
cd ~/Projects/work/repo/src     # Tedious
z repo                          # Smart jump

# JSON processing
cat data.json | python -c "..." # Verbose
jq '.users[].name' data.json    # Purpose-built

# YAML processing (K8s, Docker Compose, GitHub Actions)
yq '.services | keys' docker-compose.yml
```

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

## Tool Reference

### Search & Navigation

| Tool | Replaces | Command | Key Benefit |
|------|----------|---------|-------------|
| [ripgrep](https://github.com/BurntSushi/ripgrep) | grep | `rg` | Fastest grep, respects .gitignore |
| [fd](https://github.com/sharkdp/fd) | find | `fd` | Intuitive syntax, smart defaults |
| [fzf](https://github.com/junegunn/fzf) | - | `fzf` | Fuzzy find anything |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | cd | `z` | Learns your frequent directories |
| [broot](https://github.com/Canop/broot) | tree/ls | `br` | Interactive tree navigation |
| [ast-grep](https://github.com/ast-grep/ast-grep) | grep | `ast-grep` | Search code by AST structure |

### File Viewing & Diffing

| Tool | Replaces | Command | Key Benefit |
|------|----------|---------|-------------|
| [bat](https://github.com/sharkdp/bat) | cat | `bat` | Syntax highlighting, line numbers |
| [eza](https://github.com/eza-community/eza) | ls | `eza` | Git status, icons, tree view |
| [delta](https://github.com/dandavison/delta) | diff | `delta` | Beautiful side-by-side diffs |
| [difftastic](https://github.com/Wilfred/difftastic) | diff | `difft` | AST-aware semantic diffs |

### Data Processing

| Tool | Replaces | Command | Key Benefit |
|------|----------|---------|-------------|
| [jq](https://github.com/jqlang/jq) | - | `jq` | Query/transform JSON |
| [yq](https://github.com/mikefarah/yq) | - | `yq` | Query/transform YAML/TOML |
| [sd](https://github.com/chmln/sd) | sed | `sd` | Intuitive find & replace |

### Git & Development

| Tool | Replaces | Command | Key Benefit |
|------|----------|---------|-------------|
| [lazygit](https://github.com/jesseduffield/lazygit) | git cli | `lazygit` | Visual git TUI |
| [gh](https://cli.github.com/) | - | `gh` | GitHub from terminal |
| [tokei](https://github.com/XAMPPRocky/tokei) | cloc/wc | `tokei` | Fast code statistics |

### Python & Task Running

| Tool | Replaces | Command | Key Benefit |
|------|----------|---------|-------------|
| [uv](https://github.com/astral-sh/uv) | pip/venv | `uv` | 10-100x faster Python packaging |
| [just](https://github.com/casey/just) | make | `just` | Simple command runner |
| [httpie](https://httpie.io/) | curl | `http` | Human-friendly HTTP |
| [procs](https://github.com/dalance/procs) | ps | `procs` | Better process viewer |

### Optional

| Tool | Command | Purpose |
|------|---------|---------|
| [starship](https://starship.rs/) | - | Cross-shell prompt |
| [atuin](https://atuin.sh/) | `atuin` | Shell history sync |
| [hyperfine](https://github.com/sharkdp/hyperfine) | `hyperfine` | Command benchmarking |

Install with `--optional` flag (Windows) or `-o` flag (macOS).

## Verify Installation

Test that tools are installed and working:

```bash
# Quick check (requires just)
just verify

# With performance benchmarks
just benchmark

# Or run scripts directly:
# Windows
.\tests\verify.ps1 -Benchmark

# macOS/Linux
./tests/verify.sh --benchmark
```

Sample output:
```
╔════════════════════════════════════════╗
║   Dev Shell Tools - Verification Test  ║
╚════════════════════════════════════════╝

=== Tool Installation Check ===
  [OK] ripgrep (rg) - ripgrep 14.1.0
  [OK] fd (fd) - fd 10.1.0
  ...

=== Performance Benchmarks ===
  ripgrep vs grep:
    rg:   12ms
    grep: 156ms
    Speedup: 13x faster
```

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

### Shell initialization

**Zoxide** - add to your shell config:

```powershell
# PowerShell ($PROFILE)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
```

```bash
# Zsh (~/.zshrc) or Bash (~/.bashrc)
eval "$(zoxide init zsh)"  # or bash
```

**Broot** - run once to install shell function:
```bash
br --install
```

## Claude Code Skills

This project includes 7 skills that teach Claude Code to use these modern tools automatically.

### Installation

Copy skills to your global Claude directory:

```bash
# Unix/macOS
cp -r skills/* ~/.claude/skills/

# Windows (PowerShell)
Copy-Item -Recurse skills\* $env:USERPROFILE\.claude\skills\
```

### Available Skills

| Skill | Purpose | Tools |
|-------|---------|-------|
| `safe-file-reader` | View files without permission prompts | bat, eza, cat, head, tail |
| `structural-search` | AST-aware code search | ast-grep |
| `data-processing` | Query JSON/YAML data | jq, yq |
| `code-stats` | Codebase analysis | tokei, difft |
| `git-workflow` | Enhanced git operations | lazygit, gh, delta |
| `python-env` | Fast Python packaging | uv |
| `task-runner` | Project commands | just |

### Permissions

Add to your Claude settings (`~/.claude/settings.json`):

```json
{
  "permissions": {
    "allow": [
      "Bash(bat:*)", "Bash(eza:*)", "Bash(cat:*)", "Bash(head:*)", "Bash(tail:*)",
      "Bash(ast-grep:*)", "Bash(sg:*)", "Bash(jq:*)",
      "Bash(tokei:*)", "Bash(difft:*)", "Bash(delta:*)"
    ],
    "ask": [
      "Bash(yq:*)",
      "Bash(uv:*)",
      "Bash(gh:*)",
      "Bash(lazygit:*)",
      "Bash(just:*)"
    ]
  }
}
```

**Note**: Read-only tools are auto-approved. Tools that can modify state (`yq -i`, `uv`, `gh`, `lazygit`, `just`) prompt for confirmation. For fully permissive mode, move `ask` entries to `allow`.

## Project Structure

```
dev-shell-tools/
├── README.md           # This file
├── AGENTS.md           # AI assistant guidelines
├── justfile            # Cross-platform task runner
├── skills/             # Claude Code skills
│   ├── safe-file-reader/
│   ├── structural-search/
│   ├── data-processing/
│   ├── code-stats/
│   ├── git-workflow/
│   ├── python-env/
│   └── task-runner/
├── tests/
│   ├── verify.ps1      # Windows verification
│   └── verify.sh       # macOS/Linux verification
├── windows/
│   ├── setup.ps1       # PowerShell installer
│   └── winget-dev-tools.json
└── macos/
    ├── setup.sh        # Bash installer
    └── Brewfile        # Homebrew bundle
```

## License

MIT
