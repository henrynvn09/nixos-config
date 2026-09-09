{ pkgs, ... }:

{
  imports = [
    ./brew.nix
    ./window-manager.nix
  ];

  # Nix daemon management
  services.nix-daemon.enable = true;

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # macOS system preferences & defaults
  system = {
    stateVersion = 5;

    defaults = {
      dock = {
        autohide = true;
        tilesize = 70;
        show-recents = false;
        orientation = "bottom";
        mru-spaces = false;
      };

      trackpad = {
        Clicking = true;                # Tap to click
        TrackpadThreeFingerDrag = false;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false; # Enable key repeating in vim
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        FXPreferredViewStyle = "Nlsv";   # List view
        AppleShowAllFiles = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };
    };
  };
}
