{ config, pkgs, ... }:

{
  imports = [
    ../../modules/core
    ../../modules/darwin
  ];

  # Host identification
  networking.hostName = "Henrys-MacBook-Pro";
  networking.computerName = "Henrys-MacBook-Pro";

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
    users.henry = import ../../modules/home;
  };
}
