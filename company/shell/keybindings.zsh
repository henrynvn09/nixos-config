#!/bin/zsh
# company/shell/keybindings.zsh — Zsh keybindings & shell settings
# Source: modules/home/default.nix → initContent
#
# Pure Zsh configuration — no external dependencies required.

# ── Shell behavior ───────────────────────────────────────────────
ENABLE_CORRECTION="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
zbell_duration=60

# History
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ── Load custom user plugins if present ──────────────────────────
if [ -d "$HOME/.config/zsh/plugins" ]; then
  for plugin in "$HOME/.config/zsh/plugins"/*/*.plugin.zsh(N); do
    source "$plugin"
  done
fi

# ── Custom Keybindings ───────────────────────────────────────────
# Defined after plugins so zsh-vi-mode does not overwrite them

# Emacs-style keybindings
bindkey '^F' autosuggest-accept 2>/dev/null || true
bindkey '^W' kill-word
bindkey '^L' forward-word
bindkey '^H' backward-word
bindkey '^[[b' beginning-of-line

# Vi insert-mode keybindings
bindkey -M viins '^F' autosuggest-accept 2>/dev/null || true
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^L' forward-word
bindkey -M viins '^H' backward-delete-char

# Dircycle navigation (oh-my-zsh plugin)
bindkey '^[[1;13C' insert-cycledleft 2>/dev/null || true
bindkey '^[[1;13D' insert-cycledright 2>/dev/null || true

# fzf-dir widget (from misc-user-plugins — only if registered)
zle -N fzf-dir 2>/dev/null || true
bindkey '^E' fzf-dir 2>/dev/null || true
bindkey -M viins '^E' fzf-dir 2>/dev/null || true

# ── Syntax highlighting ─────────────────────────────────────────
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none

# ── thefuck integration ─────────────────────────────────────────
if command -v thefuck &> /dev/null; then
  eval $(thefuck --alias)
fi
