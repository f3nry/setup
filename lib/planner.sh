#!/usr/bin/env bash
# lib/planner.sh — Desired state vs actual state diffing

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

declare -a PLAN_INSTALL=()
declare -a PLAN_CONFIGURE=()
declare -a PLAN_SKIP=()
declare -a PLAN_UPDATE=()

# Check if a command exists
cmd_exists() { command -v "$1" &>/dev/null; }

# Check if a brew formula is installed
brew_installed() { brew list --formula 2>/dev/null | grep -q "^${1}$"; }

# Check if a brew cask is installed
cask_installed() { brew list --cask 2>/dev/null | grep -q "^${1}$"; }

# Check if a file/symlink exists
file_exists() { [[ -e "$1" ]] || [[ -L "$1" ]]; }

# Check if a symlink points to expected target
symlink_correct() {
  local link="$1" target="$2"
  [[ -L "$link" ]] && [[ "$(readlink "$link")" == "$target" ]]
}

# Build the full plan
build_plan() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  source "${script_dir}/config/packages.sh"

  echo -e "\n${BOLD}🔍 Scanning system state...${NC}\n"

  # --- System prerequisites ---
  if xcode-select -p &>/dev/null; then
    PLAN_SKIP+=("xcode-cli-tools")
  else
    PLAN_INSTALL+=("xcode-cli-tools")
  fi

  if [[ "$(uname -m)" == "arm64" ]] && arch -arch x86_64 /usr/bin/true 2>/dev/null; then
    PLAN_SKIP+=("rosetta-2")
  elif [[ "$(uname -m)" == "arm64" ]]; then
    PLAN_INSTALL+=("rosetta-2")
  fi

  if cmd_exists brew; then
    PLAN_SKIP+=("homebrew")
  else
    PLAN_INSTALL+=("homebrew")
  fi

  # --- Brew formulae ---
  for pkg in "${BREW_FORMULAE[@]}"; do
    if brew_installed "$pkg"; then
      PLAN_SKIP+=("brew:${pkg}")
    else
      PLAN_INSTALL+=("brew:${pkg}")
    fi
  done

  # --- Brew casks ---
  for cask in "${BREW_CASKS[@]}"; do
    if cask_installed "$cask"; then
      PLAN_SKIP+=("cask:${cask}")
    else
      PLAN_INSTALL+=("cask:${cask}")
    fi
  done

  # --- Dotfiles ---
  local dotfiles=(
    "$HOME/.tmux.conf"
    "$HOME/.config/starship.toml"
    "$HOME/.config/nvim"
  )
  local dotfile_sources=(
    "${script_dir}/dotfiles/tmux.conf"
    "${script_dir}/dotfiles/starship.toml"
    "${script_dir}/dotfiles/nvim"
  )

  for i in "${!dotfiles[@]}"; do
    local target="${dotfiles[$i]}"
    local source="${dotfile_sources[$i]}"
    local name
    name="$(basename "$target")"

    if symlink_correct "$target" "$source"; then
      PLAN_SKIP+=("config:${name}")
    elif file_exists "$target"; then
      PLAN_UPDATE+=("config:${name} (backup + relink)")
    else
      PLAN_CONFIGURE+=("config:${name}")
    fi
  done

  # --- Zsh config ---
  if [[ -f "$HOME/.zshrc" ]] && grep -q "mac-dev-setup" "$HOME/.zshrc" 2>/dev/null; then
    PLAN_SKIP+=("config:zshrc")
  else
    PLAN_CONFIGURE+=("config:zshrc")
  fi

  # --- Anaconda init ---
  if [[ -f "$HOME/.zshrc" ]] && grep -q "conda initialize" "$HOME/.zshrc" 2>/dev/null; then
    PLAN_SKIP+=("anaconda-init")
  else
    PLAN_CONFIGURE+=("anaconda-init")
  fi

  # --- tmux plugin manager ---
  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    PLAN_SKIP+=("tmux-tpm")
  else
    PLAN_INSTALL+=("tmux-tpm")
  fi

  # --- Neovim LazyVim ---
  if [[ -f "$HOME/.config/nvim/lazy-lock.json" ]]; then
    PLAN_SKIP+=("neovim-lazyvim")
  else
    PLAN_INSTALL+=("neovim-lazyvim")
  fi
}

# Display the plan
show_plan() {
  echo -e "${BOLD}📋 Setup Plan${NC}"
  echo "─────────────────────────────────────────────"

  if [[ ${#PLAN_SKIP[@]} -gt 0 ]]; then
    echo -e "${GREEN}✅ Already installed (${#PLAN_SKIP[@]}):${NC}"
    local line=""
    for item in "${PLAN_SKIP[@]}"; do
      if [[ ${#line} -gt 60 ]]; then
        echo -e "   ${DIM}${line}${NC}"
        line=""
      fi
      line+="${item}, "
    done
    [[ -n "$line" ]] && echo -e "   ${DIM}${line%, }${NC}"
  fi

  echo ""

  if [[ ${#PLAN_INSTALL[@]} -gt 0 ]]; then
    echo -e "${BLUE}📦 Will install (${#PLAN_INSTALL[@]}):${NC}"
    for item in "${PLAN_INSTALL[@]}"; do
      echo -e "   ${CYAN}${item}${NC}"
    done
  fi

  if [[ ${#PLAN_CONFIGURE[@]} -gt 0 ]]; then
    echo -e "${YELLOW}🔧 Will configure (${#PLAN_CONFIGURE[@]}):${NC}"
    for item in "${PLAN_CONFIGURE[@]}"; do
      echo -e "   ${YELLOW}${item}${NC}"
    done
  fi

  if [[ ${#PLAN_UPDATE[@]} -gt 0 ]]; then
    echo -e "${YELLOW}🔄 Will update (${#PLAN_UPDATE[@]}):${NC}"
    for item in "${PLAN_UPDATE[@]}"; do
      echo -e "   ${YELLOW}${item}${NC}"
    done
  fi

  local total_changes=$(( ${#PLAN_INSTALL[@]} + ${#PLAN_CONFIGURE[@]} + ${#PLAN_UPDATE[@]} ))

  echo ""
  echo "─────────────────────────────────────────────"

  if [[ $total_changes -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}✨ Everything is up to date! Nothing to do.${NC}"
    return 1
  fi

  echo -e "${BOLD}Total changes: ${total_changes}${NC}"
  return 0
}

# Prompt for confirmation
confirm_plan() {
  echo ""
  read -rp "Proceed? [y/N] " response
  case "$response" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) echo "Aborted."; return 1 ;;
  esac
}
