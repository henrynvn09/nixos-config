#!/bin/zsh
# company/shell/aliases.zsh — Portable shell aliases (guarded)
# Source: modules/home/default.nix → shellAliases
#
# Aliases that depend on external tools use `command -v` guards
# so they activate ONLY if the tool is installed. Safe aliases
# (built-in commands) are always active.

# ── Always-safe aliases (built-in commands) ──────────────────────
alias mv='mv -i'
alias cp='cp -i'
alias g='git'
alias dotfiles='cd ~/dotfiles'
alias '$'=''

# ── Guarded aliases (only if tool is installed) ──────────────────
command -v nvim &>/dev/null && alias vi='nvim'
command -v nvim &>/dev/null && alias vim='nvim'
command -v trash &>/dev/null && alias rm='trash'
command -v bat &>/dev/null && alias cat='bat'
command -v eza &>/dev/null && alias ls='eza'
command -v eza &>/dev/null && alias ll='eza -la --icons'
command -v eza &>/dev/null && alias la='eza -a --icons'
command -v eza &>/dev/null && alias lt='eza --tree --level=2 --icons'

# ── EXCLUDED from company config ─────────────────────────────────
# rasp = "ssh hthh@192.168.4.61"  # Personal device — not relevant
