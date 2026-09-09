{ pkgs, ... }:

{
  # Yabai tiling window manager
  services.yabai = {
    enable = true;
    enableScriptingAddition = true; # Installs sudoers entry for yabai --load-sa
  };

  # SKHD simple hotkey daemon
  services.skhd = {
    enable = true;
  };
}
