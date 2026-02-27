# 🖥️ Mac Dev Setup

One-command bootstrap for a fully configured macOS development environment.

**Includes:** Homebrew, Python 3, Go, Ruby, Anaconda, Node.js, Docker, tmux, Neovim (LazyVim), Starship prompt, zsh plugins, iTerm2, Nerd Fonts, and more.

## Quick Start

```bash
git clone https://github.com/YOUR_USER/mac-dev-setup.git ~/.mac-dev-setup
cd ~/.mac-dev-setup
./setup.sh
```

That's it. The script is idempotent — run it again anytime to converge on the desired state.

## What It Does

### 🔍 Plan Mode (default)

Before changing anything, the script scans your system and shows a **diff plan** of what will be installed, updated, or configured:

```
📋 Setup Plan
─────────────────────────────────
✅ Already installed: homebrew, git, python3
📦 Will install:     go, ruby, anaconda, tmux, neovim, starship
🔧 Will configure:   zsh, tmux, neovim, starship, iterm2
⏭️  Skipping:         xcode-tools (already installed)
─────────────────────────────────
Proceed? [y/N/d]  (d = dry-run details)
```

### 🛠️ What Gets Installed

| Category | Tools |
|----------|-------|
| **System** | Xcode CLI Tools, Homebrew, Rosetta 2 (Apple Silicon) |
| **Languages** | Python 3, Go, Ruby, Node.js (LTS) |
| **Data Science** | Anaconda (full) |
| **Containers** | Docker Desktop |
| **Editor** | Neovim + LazyVim with LSPs for all languages |
| **Terminal** | tmux, Starship prompt, zsh-autosuggestions, zsh-syntax-highlighting, fzf |
| **Fonts** | JetBrains Mono Nerd Font |
| **Apps** | iTerm2, Visual Studio Code |
| **CLI Tools** | ripgrep, fd, bat, eza, jq, yq, htop, tldr, gh, lazygit, lazydocker |

### 🔧 What Gets Configured

- **zsh** — history, completions, keybindings, autosuggestions, syntax highlighting, fzf integration
- **tmux** — prefix `C-a`, vim nav, mouse, true color, Catppuccin theme, resurrect/continuum
- **Neovim** — LazyVim with Python/Go/Ruby/Docker language extras
- **Starship** — Catppuccin-themed prompt with language version display
- **Git** — sensible defaults (asks for name/email if not set)

## Options

```bash
./setup.sh              # Interactive plan + install
./setup.sh --plan       # Show plan only, don't install anything
./setup.sh --yes        # Skip confirmation, apply everything
./setup.sh --skip brew  # Skip a specific module
./setup.sh --only tmux  # Run only a specific module
```

## Modules

Each component is a standalone module in `modules/`. You can run any individually:

```bash
./modules/tmux.sh       # Just set up tmux
./modules/neovim.sh     # Just set up neovim
./modules/zsh.sh        # Just set up zsh config
```

## Customization

- Edit `config/packages.sh` to add/remove brew packages
- Edit dotfiles in `dotfiles/` directly
- Add your own modules in `modules/`

## Uninstall

Dotfiles are symlinked, so removing them is clean:

```bash
./setup.sh --unlink     # Remove symlinks, restore backups
```

## Requirements

- macOS 12+ (Monterey or later)
- Internet connection for initial setup
