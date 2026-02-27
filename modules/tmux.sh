#!/usr/bin/env bash
# modules/tmux.sh — Tmux configuration + TPM

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

setup_tmux() {
  log_step "Tmux"

  # Symlink tmux.conf
  safe_symlink "${SCRIPT_DIR}/dotfiles/tmux.conf" "$HOME/.tmux.conf"

  # Install TPM
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    log_info "Installing tmux plugin manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    log_success "TPM installed. Press prefix + I inside tmux to install plugins."
  else
    log_success "TPM already installed"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_tmux
fi
