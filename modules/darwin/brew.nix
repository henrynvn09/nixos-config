{ pkgs, ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none"; # Prevent unintended deletion of manually installed packages
    };

    taps = [];

    # macOS-specific CLI tools managed via Homebrew formulae
    brews = [
      "brightness"     # Required by Raycast monitor & brightness scripts
      "displayplacer"  # Required by Raycast display layout switcher extension
    ];

    # macOS GUI applications managed via Homebrew casks
    casks = [
      # Terminal & IDEs
      "alacritty"
      "intellij-idea"

      # Browsers
      "arc"
      "firefox"
      "google-chrome"

      # Productivity & Communication
      "obsidian"
      "raycast"
      "discord"
      "anki"
      "calibre"

      # System Utilities & Peripherals
      "battery"
      "betterdisplay"
      "bluesnooze"
      "appcleaner"
      "jordanbaird-ice"
      "mac-mouse-fix"
      "middleclick"
      "the-unarchiver"
      "betterzip"
      "kap"
      "postman"
      "phoenix-slides"

      # Developer Fonts
      "font-jetbrains-mono-nerd-font"
      "font-fira-code"
      "font-caskaydia-cove-nerd-font"
      "font-0xproto-nerd-font"
      "font-atkinson-hyperlegible"
      "font-mononoki-nerd-font"
      "font-sauce-code-pro-nerd-font"
    ];
  };
}
