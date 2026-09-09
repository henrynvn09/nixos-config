{ pkgs, ... }:

{
  # Yabai tiling window manager
  services.yabai = {
    enable = true;
    enableScriptingAddition = false;
  };

  # SKHD simple hotkey daemon
  services.skhd = {
    enable = true;
  };
}
