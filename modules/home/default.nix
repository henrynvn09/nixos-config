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
    };

    initContent = ''
      # Accept autosuggestion with Ctrl-F
      bindkey '^F' forward-word

      # Load custom user plugins (q, photo-editing-user, misc-user-plugins, etc.)
      if [ -d "$HOME/.config/zsh/plugins" ]; then
        for plugin in "$HOME/.config/zsh/plugins"/*/*.plugin.zsh(N); do
          source "$plugin"
        done
      fi

      # NVM environment (if installed)
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # SDKMAN environment (if installed)
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

      # Load local environment overrides if present
      if [ -f "$HOME/.env.local" ]; then
        source "$HOME/.env.local"
      fi

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
