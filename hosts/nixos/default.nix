{ config, pkgs, ... }:

{
  imports = [
    ../../modules/core
  ];

  networking.hostName = "nixos";

  users.users.henry = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.henry = import ../../modules/home;
  };

  system.stateVersion = "24.05";
}
