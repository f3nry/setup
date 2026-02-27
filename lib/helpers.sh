#!/usr/bin/env bash
# lib/helpers.sh — Shared utility functions

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}ℹ ${NC} $*"; }
log_success() { echo -e "${GREEN}✅${NC} $*"; }
log_warn()    { echo -e "${YELLOW}⚠️ ${NC} $*"; }
log_error()   { echo -e "${RED}❌${NC} $*"; }
log_step()    { echo -e "\n${BOLD}▶ $*${NC}"; }

# Backup a file/directory before replacing
backup_if_exists() {
  local target="$1"
  if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
    local backup="${target}.backup.$(date +%Y%m%d-%H%M%S)"
    log_warn "Backing up existing ${target} → ${backup}"
    mv "$target" "$backup"
  elif [[ -L "$target" ]]; then
    rm "$target"
  fi
}

# Create a symlink with backup
safe_symlink() {
  local source="$1" target="$2"
  backup_if_exists "$target"
  mkdir -p "$(dirname "$target")"
  ln -sf "$source" "$target"
  log_success "Linked ${target} → ${source}"
}

# Check if running on Apple Silicon
is_apple_silicon() { [[ "$(uname -m)" == "arm64" ]]; }

# Get the Homebrew prefix
brew_prefix() {
  if is_apple_silicon; then
    echo "/opt/homebrew"
  else
    echo "/usr/local"
  fi
}
