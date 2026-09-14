{ config, pkgs, lib, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in
{
  # Out-of-store symlinks for active dotfiles (live-editable without rebuilds)
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/nvim";
  xdg.configFile."alacritty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/alacritty";
  xdg.configFile."yabai".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/yabai";
  xdg.configFile."skhd".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/skhd";
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/starship/starship.toml";
  xdg.configFile."zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/zsh";

  # macOS-specific Application Support dotfiles
  home.file = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    "Library/Application Support/com.nuebling.mac-mouse-fix/config.plist".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/mac-mouse-fix/config.plist";
  };

  # Link Firefox userChrome.css into default profile if present
  home.activation.linkFirefoxChrome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    FIREFOX_DIR="$HOME/Library/Application Support/Firefox/Profiles"
    if [ -d "$FIREFOX_DIR" ]; then
      for profile in "$FIREFOX_DIR"/*.default*; do
        if [ -d "$profile" ]; then
          mkdir -p "$profile/chrome"
          ln -sfn "${dotfilesDir}/config/firefox/chrome/userChrome.css" "$profile/chrome/userChrome.css" 2>/dev/null || true
          ln -sfn "${dotfilesDir}/config/firefox/chrome/userContent.css" "$profile/chrome/userContent.css" 2>/dev/null || true
        fi
      done
    fi
  '';
}
