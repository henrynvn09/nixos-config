{ config, pkgs, ... }:

{
  imports = [
    ../../modules/core
  ];

  networking.hostName = "nixos";

  # Bootloader setup (standard systemd-boot for UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Basic root filesystem declaration for flake validation
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Shell configuration
  programs.zsh.enable = true;

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
