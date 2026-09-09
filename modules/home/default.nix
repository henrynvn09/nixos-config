{ config, pkgs, lib, ... }:

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

  # Home Manager state version
  home.stateVersion = "24.05";

  # Session environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
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

      # Load local environment overrides if present
      if [ -f "$HOME/.env.local" ]; then
        source "$HOME/.env.local"
      fi

      # Add Homebrew & personal scripts to PATH
      export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
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
