#!/usr/bin/env bash
# config/packages.sh — Central package list
# Edit these arrays to customize what gets installed.

# Homebrew formulae
BREW_FORMULAE=(
  # Core
  git
  curl
  wget

  # Languages
  python3
  go
  ruby
  node

  # Terminal tools
  tmux
  neovim
  starship
  fzf
  ripgrep
  fd
  bat
  eza
  jq
  yq
  htop
  tldr
  tree

  # Zsh plugins
  zsh-autosuggestions
  zsh-syntax-highlighting

  # Git tools
  gh
  lazygit
  lazydocker

  # macOS clipboard for tmux
  reattach-to-user-namespace
)

# Homebrew casks
BREW_CASKS=(
  iterm2
  visual-studio-code
  docker
  anaconda
  ollama
  font-jetbrains-mono-nerd-font
)

# Neovim LazyVim extras to enable
LAZYVIM_EXTRAS=(
  "lang.python"
  "lang.go"
  "lang.ruby"
  "lang.docker"
)

# Anaconda path (Homebrew installs here on Apple Silicon)
ANACONDA_PATH="/opt/homebrew/anaconda3"
# Intel Macs:
# ANACONDA_PATH="/usr/local/anaconda3"
