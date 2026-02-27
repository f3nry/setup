#!/usr/bin/env bash
# modules/git.sh — Git configuration

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

setup_git() {
  log_step "Git Configuration"

  # Global gitignore
  safe_symlink "${SCRIPT_DIR}/dotfiles/gitignore_global" "$HOME/.gitignore_global"
  git config --global core.excludesfile "$HOME/.gitignore_global"
  log_success "Global gitignore configured"

  # Sensible defaults
  git config --global init.defaultBranch main
  git config --global pull.rebase true
  git config --global push.autoSetupRemote true
  git config --global core.editor nvim
  git config --global diff.algorithm histogram
  git config --global merge.conflictstyle zdiff3
  git config --global rerere.enabled true
  git config --global column.ui auto
  git config --global branch.sort -committerdate

  # Prompt for name/email if not set
  if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
    echo ""
    read -rp "Git user name: " git_name
    git config --global user.name "$git_name"
  fi

  if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
    read -rp "Git email: " git_email
    git config --global user.email "$git_email"
  fi

  log_success "Git configured (user: $(git config --global user.name))"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_git
fi
