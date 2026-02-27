#!/usr/bin/env bash
# modules/starship.sh — Starship prompt configuration

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

setup_starship() {
  log_step "Starship Prompt"

  mkdir -p "$HOME/.config"
  safe_symlink "${SCRIPT_DIR}/dotfiles/starship.toml" "$HOME/.config/starship.toml"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_starship
fi
