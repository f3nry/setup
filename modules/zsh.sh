#!/usr/bin/env bash
# modules/zsh.sh — Zsh configuration

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/helpers.sh"

setup_zsh() {
  log_step "Zsh Configuration"

  local zshrc="$HOME/.zshrc"
  local marker="# >>> mac-dev-setup >>>"
  local marker_end="# <<< mac-dev-setup <<<"

  # Remove old managed block if present
  if grep -q "$marker" "$zshrc" 2>/dev/null; then
    log_info "Updating existing mac-dev-setup zsh config..."
    sed -i '' "/$marker/,/$marker_end/d" "$zshrc"
  fi

  local brew_prefix
  brew_prefix="$(brew_prefix)"

  cat >> "$zshrc" << ZSHEOF
${marker}
# ── History ────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# ── Completion ─────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "\${(s.:.)LS_COLORS}"

# ── History search with arrow keys ─────────────────
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# ── Plugins ────────────────────────────────────────
[[ -f "${brew_prefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "${brew_prefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "${brew_prefix}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "${brew_prefix}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── fzf ────────────────────────────────────────────
[[ -f "${brew_prefix}/opt/fzf/shell/completion.zsh" ]] && source "${brew_prefix}/opt/fzf/shell/completion.zsh"
[[ -f "${brew_prefix}/opt/fzf/shell/key-bindings.zsh" ]] && source "${brew_prefix}/opt/fzf/shell/key-bindings.zsh"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# ── Aliases ────────────────────────────────────────
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias lt="eza --tree --level=2 --icons"
alias cat="bat --style=auto"
alias vim="nvim"
alias lg="lazygit"
alias ld="lazydocker"

# ── Starship prompt ────────────────────────────────
eval "\$(starship init zsh)"

# ── Go ─────────────────────────────────────────────
export GOPATH="\$HOME/go"
export PATH="\$GOPATH/bin:\$PATH"

# ── Homebrew ───────────────────────────────────────
export PATH="${brew_prefix}/bin:\$PATH"
${marker_end}
ZSHEOF

  log_success "Zsh configured with history, completions, plugins, aliases, and Starship"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_zsh
fi
