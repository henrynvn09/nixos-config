{ config, pkgs, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in
{
  # Out-of-store symlinks for active dotfiles (live-editable without rebuilds)
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/nvim";
  xdg.configFile."alacritty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/alacritty";
  xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/kitty";
  xdg.configFile."yabai".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/yabai";
  xdg.configFile."skhd".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/skhd";
  xdg.configFile."raycast".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/raycast";
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/starship/starship.toml";
}
