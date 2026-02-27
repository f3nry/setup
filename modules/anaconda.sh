#!/usr/bin/env bash
# modules/anaconda.sh — Anaconda initialization

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"
source "${SCRIPT_DIR}/config/packages.sh"

setup_anaconda() {
  log_step "Anaconda"

  # Determine anaconda path (Apple Silicon vs Intel)
  local conda_path
  if is_apple_silicon; then
    conda_path="/opt/homebrew/anaconda3"
  else
    conda_path="/usr/local/anaconda3"
  fi

  if [[ ! -d "$conda_path" ]]; then
    log_warn "Anaconda not found at ${conda_path}. Install it first via brew module."
    return 1
  fi

  # Initialize conda for zsh
  if ! grep -q "conda initialize" "$HOME/.zshrc" 2>/dev/null; then
    log_info "Initializing conda for zsh..."
    "${conda_path}/bin/conda" init zsh
    log_success "Conda initialized"
  else
    log_success "Conda already initialized in .zshrc"
  fi

  # Disable auto-activate base (keeps prompt clean)
  "${conda_path}/bin/conda" config --set auto_activate_base false
  log_success "Disabled auto_activate_base"

  # Update conda
  log_info "Updating conda..."
  "${conda_path}/bin/conda" update -n base conda -y --quiet || true
  log_success "Conda updated"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_anaconda
fi
