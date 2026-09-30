#!/bin/zsh
# company/shell/fzf.zsh — FZF fuzzy finder integration (guarded)
# Source: modules/home/default.nix → initContent
#
# Only configures FZF if the binary exists. Sub-features (fd-based
# search, bat-based preview) only activate if those tools exist too.

if command -v fzf &>/dev/null; then
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

  # Use fd for file/directory search if available
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --ignore-case --exclude ".*"'
    export FZF_CTRL_T_COMMAND='fd --type f --hidden --ignore-case --exclude ".*"'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude ".*"'
  fi

  # Use bat for preview if available
  if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} | head -100'"
  fi

  # Use tree for directory preview if available
  if command -v tree &>/dev/null; then
    export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -100'"
  fi

  # Source FZF shell integration (keybindings + completion)
  if [ -f "$HOME/.fzf.zsh" ]; then
    source "$HOME/.fzf.zsh"
  elif [ -f "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" ]; then
    source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
    source "/opt/homebrew/opt/fzf/shell/completion.zsh"
  elif [ -f "/usr/local/opt/fzf/shell/key-bindings.zsh" ]; then
    source "/usr/local/opt/fzf/shell/key-bindings.zsh"
    source "/usr/local/opt/fzf/shell/completion.zsh"
  fi
fi
