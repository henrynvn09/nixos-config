{ config, pkgs, lib, ... }:

let
  commonCliPackages = with pkgs; [
    # Core essentials
    git
    neovim
    curl
    wget
    just

    # Modern CLI replacements
    ripgrep
    fd
    bat
    eza
    tree
    jq
    fzf
    tldr
    trash-cli

    # Script evaluation & media tools
    bc
    imagemagick
    exiftool
    yadm
    mutt

    # Development tools & runtimes
    cmake
    go
    lua
    uv

    # Secrets management tooling
    sops
    age

    # Archives & utilities
    ffmpeg
    yt-dlp
    zip
    unzip
  ];
in
{
  imports = [
    ./dotfiles.nix
    ../core/git.nix
  ];

  # User identity & home directory
  home.username = lib.mkDefault "henry";
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/henry" else "/home/henry"
  );

  # Home Manager state version & stability guards
  home.stateVersion = "24.05";
  home.enableNixpkgsReleaseCheck = false;

  # Ensure standalone Home Manager installs all core CLI packages
  home.packages = commonCliPackages;

  # Session environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    DOWNLOADS = "${config.home.homeDirectory}/Downloads";
    OBSIDIAN = "${config.home.homeDirectory}/Documents/obsidian";
    OBSIDIAN_CURRENT_CLASS = "${config.home.homeDirectory}/Documents/obsidian/109 - current classes";
    ANDROID_HOME = "${config.home.homeDirectory}/Library/Android/sdk";
  };

  # Shell configuration (Zsh)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      share = true;
      ignoreDups = true;
    };

    # Oh My Zsh integration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "z"
        "gitignore"
        "zbell"
        "copypath"
        "sprunge"
        "dircycle"
        "docker"
      ];
    };

    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      rm = "trash";
      mv = "mv -i";
      cp = "cp -i";
      ls = "eza";
      ll = "eza -la --icons";
      la = "eza -a --icons";
      lt = "eza --tree --level=2 --icons";
      cat = "bat";
      g = "git";
      dotfiles = "cd ~/dotfiles";
      rasp = "ssh hthh@192.168.4.61";
      "$" = "";
    };

    initContent = ''
      ENABLE_CORRECTION="true"
      DISABLE_UNTRACKED_FILES_DIRTY="true"
      zbell_duration=60

      # Load custom user plugins (q, photo-editing-user, misc-user-plugins, zsh-vi-mode, etc.)
      if [ -d "$HOME/.config/zsh/plugins" ]; then
        for plugin in "$HOME/.config/zsh/plugins"/*/*.plugin.zsh(N); do
          source "$plugin"
        done
      fi

      # Custom Keybindings (defined after plugins so zsh-vi-mode does not overwrite them)
      bindkey '^F' autosuggest-accept
      bindkey '^W' kill-word
      bindkey '^L' forward-word
      bindkey '^H' backward-word
      bindkey '^[[b' beginning-of-line

      bindkey -M viins '^F' autosuggest-accept
      bindkey -M viins '^W' backward-kill-word
      bindkey -M viins '^L' forward-word
      bindkey -M viins '^H' backward-delete-char

      # dircycle navigation
      bindkey '^[[1;13C' insert-cycledleft
      bindkey '^[[1;13D' insert-cycledright

      # FZF custom previews & commands
      export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude ".*"'
      export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -100'"
      export FZF_CTRL_T_COMMAND='fd --type f --hidden --ignore-case --exclude ".*"'
      export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} | head -100'"

      # Enable fzf keybindings if present
      [ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

      # Custom syntax highlight styles
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[path]=none

      # thefuck integration
      if command -v thefuck &> /dev/null; then
        eval $(thefuck --alias)
      fi

      # Register fzf-dir widget from misc-user-plugins
      zle -N fzf-dir 2>/dev/null || true
      bindkey '^E' fzf-dir
      bindkey -M viins '^E' fzf-dir

      # Load local environment overrides if present
      if [ -f "$HOME/.env.local" ]; then
        source "$HOME/.env.local"
      fi

      # NVM environment (if installed)
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # SDKMAN environment (if installed)
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

      # Dynamic PATH detection for Homebrew & user binaries
      if [ -d "/opt/homebrew/bin" ]; then
        export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
      elif [ -d "/usr/local/bin" ]; then
        export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"
      else
        export PATH="$HOME/.local/bin:$PATH"
      fi
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # FZF fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Bat syntax-highlighted cat
  programs.bat = {
    enable = true;
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
