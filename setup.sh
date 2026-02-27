#!/usr/bin/env bash
# setup.sh — Mac Dev Setup orchestrator
# Usage:
#   ./setup.sh              Interactive plan + install
#   ./setup.sh --plan       Show plan only
#   ./setup.sh --yes        Skip confirmation
#   ./setup.sh --only tmux  Run only one module
#   ./setup.sh --skip brew  Skip a module
#   ./setup.sh --unlink     Remove symlinks, restore backups

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"
source "${SCRIPT_DIR}/lib/planner.sh"
source "${SCRIPT_DIR}/config/packages.sh"

# ── Parse arguments ────────────────────────────────
PLAN_ONLY=false
AUTO_YES=false
ONLY_MODULE=""
SKIP_MODULE=""
UNLINK=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan)    PLAN_ONLY=true; shift ;;
    --yes|-y)  AUTO_YES=true; shift ;;
    --only)    ONLY_MODULE="$2"; shift 2 ;;
    --skip)    SKIP_MODULE="$2"; shift 2 ;;
    --unlink)  UNLINK=true; shift ;;
    -h|--help)
      echo "Usage: ./setup.sh [--plan] [--yes] [--only MODULE] [--skip MODULE] [--unlink]"
      echo ""
      echo "Modules: system, brew, anaconda, tmux, neovim, starship, zsh, git"
      exit 0
      ;;
    *) log_error "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Unlink mode ────────────────────────────────────
if $UNLINK; then
  log_step "Removing symlinks..."

  for link in "$HOME/.tmux.conf" "$HOME/.config/starship.toml" "$HOME/.gitignore_global"; do
    if [[ -L "$link" ]]; then
      rm "$link"
      log_success "Removed $link"

      # Restore backup if exists
      latest_backup=$(ls -t "${link}.backup."* 2>/dev/null | head -1 || true)
      if [[ -n "$latest_backup" ]]; then
        mv "$latest_backup" "$link"
        log_success "Restored backup: $latest_backup"
      fi
    fi
  done

  # Remove managed zsh block
  if [[ -f "$HOME/.zshrc" ]]; then
    sed -i '' '/# >>> mac-dev-setup >>>/,/# <<< mac-dev-setup <<</d' "$HOME/.zshrc"
    log_success "Removed mac-dev-setup block from .zshrc"
  fi

  log_success "Unlink complete!"
  exit 0
fi

# ── Banner ─────────────────────────────────────────
echo ""
echo -e "${BOLD}  🖥️  Mac Dev Setup${NC}"
echo -e "  ${DIM}Python · Go · Ruby · Docker · tmux · Neovim · Starship${NC}"
echo ""

# ── Run a single module ────────────────────────────
run_module() {
  local module="$1"

  # Skip check
  if [[ -n "$SKIP_MODULE" ]] && [[ "$module" == "$SKIP_MODULE" ]]; then
    log_info "Skipping ${module} (--skip)"
    return 0
  fi

  # Only check
  if [[ -n "$ONLY_MODULE" ]] && [[ "$module" != "$ONLY_MODULE" ]]; then
    return 0
  fi

  source "${SCRIPT_DIR}/modules/${module}.sh"

  case "$module" in
    system)   install_system ;;
    brew)     install_brew_packages ;;
    anaconda) setup_anaconda ;;
    tmux)     setup_tmux ;;
    neovim)   setup_neovim ;;
    starship) setup_starship ;;
    zsh)      setup_zsh ;;
    git)      setup_git ;;
  esac
}

# ── Plan phase ─────────────────────────────────────
if [[ -z "$ONLY_MODULE" ]]; then
  build_plan

  if ! show_plan; then
    exit 0
  fi

  if $PLAN_ONLY; then
    exit 0
  fi

  if ! $AUTO_YES; then
    if ! confirm_plan; then
      exit 0
    fi
  fi
fi

# ── Execute ────────────────────────────────────────
echo ""
log_step "Starting setup..."

MODULES=(system brew anaconda tmux neovim starship zsh git)

for module in "${MODULES[@]}"; do
  run_module "$module" || log_warn "Module '${module}' had issues, continuing..."
done

# ── Install dev launcher ───────────────────────────
chmod +x "${SCRIPT_DIR}/bin/dev"
if [[ ! -L "/usr/local/bin/dev" ]] && [[ ! -f "/usr/local/bin/dev" ]]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "${SCRIPT_DIR}/bin/dev" "$HOME/.local/bin/dev"

  # Ensure ~/.local/bin is in PATH
  if ! grep -q '.local/bin' "$HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
  fi
  log_success "Installed 'dev' command → run 'dev' to launch tmux session"
fi

# ── Done ───────────────────────────────────────────
echo ""
echo "─────────────────────────────────────────────"
echo -e "${GREEN}${BOLD}🎉 Setup complete!${NC}"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "  1. Restart your terminal (or: ${CYAN}source ~/.zshrc${NC})"
echo -e "  2. In iTerm2: Set font to ${CYAN}JetBrainsMono Nerd Font${NC}"
echo -e "  3. In iTerm2: Set Option keys to ${CYAN}Esc+${NC} (Settings → Profiles → Keys)"
echo -e "  4. Run ${CYAN}dev${NC} to launch a tmux dev session"
echo -e "  5. In tmux: Press ${CYAN}Ctrl-a + I${NC} to install tmux plugins"
echo ""
echo -e "  ${DIM}Run ./setup.sh again anytime to converge on desired state.${NC}"
echo ""
