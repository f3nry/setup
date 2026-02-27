#!/usr/bin/env bash
# modules/system.sh — Xcode CLI Tools, Rosetta 2, Homebrew

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

install_system() {
  log_step "System Prerequisites"

  # Xcode Command Line Tools
  if ! xcode-select -p &>/dev/null; then
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press any key after Xcode tools finish installing..."
    read -n 1 -s -r
  else
    log_success "Xcode CLI Tools already installed"
  fi

  # Rosetta 2 (Apple Silicon only)
  if is_apple_silicon; then
    if ! arch -arch x86_64 /usr/bin/true 2>/dev/null; then
      log_info "Installing Rosetta 2..."
      softwareupdate --install-rosetta --agree-to-license
    else
      log_success "Rosetta 2 already installed"
    fi
  fi

  # Homebrew
  if ! command -v brew &>/dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for this session
    if is_apple_silicon; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    log_success "Homebrew already installed"
    log_info "Updating Homebrew..."
    brew update
  fi
}

# Allow running standalone
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_system
fi
