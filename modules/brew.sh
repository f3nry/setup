#!/usr/bin/env bash
# modules/brew.sh — Install Homebrew formulae and casks

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"
source "${SCRIPT_DIR}/config/packages.sh"

## Map Homebrew cask names to their /Applications/*.app paths.
## Returns empty string for casks that don't install .app bundles (fonts, CLIs, etc.)
cask_app_path() {
  case "$1" in
    iterm2)               echo "/Applications/iTerm.app" ;;
    visual-studio-code)   echo "/Applications/Visual Studio Code.app" ;;
    docker)               echo "/Applications/Docker.app" ;;
    google-chrome)        echo "/Applications/Google Chrome.app" ;;
    firefox)              echo "/Applications/Firefox.app" ;;
    slack)                echo "/Applications/Slack.app" ;;
    discord)              echo "/Applications/Discord.app" ;;
    spotify)              echo "/Applications/Spotify.app" ;;
    zoom)                 echo "/Applications/zoom.us.app" ;;
    notion)               echo "/Applications/Notion.app" ;;
    1password)            echo "/Applications/1Password.app" ;;
    raycast)              echo "/Applications/Raycast.app" ;;
    rectangle)            echo "/Applications/Rectangle.app" ;;
    obsidian)             echo "/Applications/Obsidian.app" ;;
    postman)              echo "/Applications/Postman.app" ;;
    figma)                echo "/Applications/Figma.app" ;;
    tableplus)            echo "/Applications/TablePlus.app" ;;
    insomnia)             echo "/Applications/Insomnia.app" ;;
    warp)                 echo "/Applications/Warp.app" ;;
    alacritty)            echo "/Applications/Alacritty.app" ;;
    kitty)                echo "/Applications/kitty.app" ;;
    brave-browser)        echo "/Applications/Brave Browser.app" ;;
    arc)                  echo "/Applications/Arc.app" ;;
    linear-linear)        echo "/Applications/Linear.app" ;;
    the-unarchiver)       echo "/Applications/The Unarchiver.app" ;;
    vlc)                  echo "/Applications/VLC.app" ;;
    *)                    echo "" ;;
  esac
}

install_brew_packages() {
  log_step "Homebrew Packages"

  # Tap cask-fonts for Nerd Fonts
  brew tap homebrew/cask-fonts 2>/dev/null || true

  # Install formulae
  local installed_formulae
  installed_formulae=$(brew list --formula 2>/dev/null)

  for pkg in "${BREW_FORMULAE[@]}"; do
    if echo "$installed_formulae" | grep -q "^${pkg}$"; then
      log_success "${pkg} already installed"
    else
      log_info "Installing ${pkg}..."
      brew install "$pkg" || log_warn "Failed to install ${pkg}, continuing..."
    fi
  done

  # Install casks (skip if already in /Applications)
  local installed_casks
  installed_casks=$(brew list --cask 2>/dev/null)

  for cask in "${BREW_CASKS[@]}"; do
    local app_path
    app_path=$(cask_app_path "$cask")

    if echo "$installed_casks" | grep -q "^${cask}$"; then
      log_success "${cask} already installed (brew)"
    elif [[ -n "$app_path" ]] && [[ -d "$app_path" ]]; then
      log_success "${cask} already installed (${app_path})"
    else
      log_info "Installing ${cask}..."
      brew install --cask "$cask" || log_warn "Failed to install ${cask}, continuing..."
    fi
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_brew_packages
fi
