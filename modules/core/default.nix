{ pkgs, ... }:

{
  imports = [
    ./packages.nix
  ];

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  # Allow unfree / proprietary packages
  nixpkgs.config.allowUnfree = true;
}
