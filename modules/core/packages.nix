{ pkgs, ... }:

let
  commonPackages = with pkgs; [
    # Core essentials
    git
    neovim
    curl
    wget
    just

    # Modern CLI replacements
    ripgrep
    fd
    bat
    eza
    tree
    jq
    fzf
    tldr
    trash-cli

    # Script evaluation & media tools
    bc
    imagemagick
    exiftool
    yadm
    mutt

    # Development tools & runtimes
    cmake
    go
    lua
    uv

    # Secrets management tooling
    sops
    age

    # Archives & utilities
    ffmpeg
    yt-dlp
    zip
    unzip
  ];
in
{
  # System-level packages for macOS and NixOS
  environment.systemPackages = commonPackages;

  # Export package list for Home Manager consumption
  _module.args.commonPackages = commonPackages;
}
