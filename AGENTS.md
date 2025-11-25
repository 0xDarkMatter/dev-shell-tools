# Agent Guidelines for Dev Shell Tools

Guidelines for AI coding assistants (Claude Code, Codex CLI, Gemini CLI, Amp, Aider, etc.)

## Available CLI Tools

This environment has modern CLI tools installed. Prefer these over traditional equivalents:

| Instead of | Use | Example |
|------------|-----|---------|
| `grep -r` | `rg` | `rg "pattern" --type py` |
| `find` | `fd` | `fd -e js` |
| `cat` | `bat` | `bat file.py` |
| `ls` | `eza` | `eza -la --git` |
| `sed` | `sd` | `sd 'old' 'new' file` |
| `pip install` | `uv pip install` | `uv pip install requests` |
| `tree` | `br` | `br` (interactive tree navigation) |

## Token Efficiency Guidelines

### Search Strategy
- Use `ast-grep` for structural code queries (precise matches, fewer tokens)
- Use `fd -e py | xargs ...` to scope searches narrowly
- Apply `jq` filtering before displaying JSON to reduce output size
- Use `tokei` for quick codebase stats instead of manual counting

### Reducing Output Noise
- `rg -l pattern` lists files only (no content)
- `fd --max-depth 2` limits directory traversal
- `jq '.data[] | {id, name}'` extracts only needed fields
- `yq '.services | keys' docker-compose.yml` extracts specific YAML fields
- `br` for interactive directory exploration (avoids dumping full tree)
- `difft` shows semantic changes, less noise than line diffs

### Project Commands
Check for a `justfile` in the project root for common operations:
```bash
just        # list available commands
just test   # run tests
just build  # build project
```

## Git Workflows

- Use `lazygit` for complex staging/branching operations
- Use `gh pr create` for pull requests from terminal
- Configure `delta` or `difft` as git pager for readable diffs

## Python Projects

- Use `uv` for all Python package operations (10-100x faster than pip)
- `uv venv` creates virtual environments
- `uv pip compile` for lockfiles
- `uv run` executes in project environment
