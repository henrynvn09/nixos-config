{ pkgs, ... }:

{
  # Core CLI packages available on all machines
  environment.systemPackages = with pkgs; [
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

    # Development tools & runtimes
    cmake
    go
    lua
    uv

    # Media & utilities
    ffmpeg
    yt-dlp
    zip
    unzip
  ];
}
