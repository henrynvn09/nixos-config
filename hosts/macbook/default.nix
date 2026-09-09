{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/core
    ../../modules/darwin
  ];

  # Host identification (fallback defaults without forcing rebrand on other machines)
  networking.hostName = lib.mkDefault "Henrys-MacBook-Pro";
  networking.computerName = lib.mkDefault "Henrys-MacBook-Pro";

  # User account configuration
  users.users.henry = {
    name = "henry";
    home = "/Users/henry";
    shell = pkgs.zsh;
  };

  # Home Manager integration inside nix-darwin
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup"; # Automatically backup colliding files (prevents activation aborts)
    users.henry = import ../../modules/home;
  };
}
