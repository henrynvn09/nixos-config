{ pkgs, ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none"; # Prevent unintended deletion of manually installed packages
    };

    taps = [
      "koekeishiya/formulae"
    ];

    # macOS-specific CLI tools managed via Homebrew formulae
    brews = [
      "ddcctl"
      "displayplacer"
    ];

    # macOS GUI applications managed via Homebrew casks
    casks = [
      # Editors & IDEs
      "cursor"
      "visual-studio-code"
      "alacritty"
      "kitty"
      "sublime-text"
      "intellij-idea"
      "android-studio"

      # Browsers
      "arc"
      "brave-browser"
      "firefox"
      "floorp"
      "google-chrome"

      # Productivity & Communication
      "obsidian"
      "raycast"
      "discord"
      "slack"
      "anki"
      "calibre"

      # System Utilities & Peripherals
      "battery"
      "battery-toolkit"
      "bluesnooze"
      "appcleaner"
      "mac-mouse-fix"
      "middleclick"
      "the-unarchiver"
      "betterzip"
      "kap"
      "postman"
      "ngrok"

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
