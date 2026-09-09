# Justfile - Command runner for Nix dotfiles
set shell := ["bash", "-cu"]

default:
    @just --list

# Switch system configuration (auto-detects macOS vs Linux)
switch:
    #!/usr/bin/env bash
    set -euo pipefail
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ "$(uname)" == "Darwin" ]]; then
        if command -v darwin-rebuild &> /dev/null; then
            darwin-rebuild switch --flake "${DOTFILES_DIR}#macbook"
        else
            nix run nix-darwin -- switch --flake "${DOTFILES_DIR}#macbook"
        fi
    elif command -v nixos-rebuild &> /dev/null; then
        sudo nixos-rebuild switch --flake "${DOTFILES_DIR}#nixos"
    else
        if command -v home-manager &> /dev/null; then
            home-manager switch --flake "${DOTFILES_DIR}#henry" -b backup
        else
            nix run home-manager -- switch --flake "${DOTFILES_DIR}#henry" -b backup
        fi
    fi

# Check flake syntax and inputs
check:
    nix flake check

# Update all flake inputs
update:
    nix flake update

# Garbage collect user and system generations to truly free disk space
gc:
    #!/usr/bin/env bash
    echo "Collecting user profile generations..."
    nix-collect-garbage -d
    if [[ "$(uname)" == "Darwin" ]] || command -v nixos-rebuild &> /dev/null; then
        echo "Collecting system profile generations (requires sudo)..."
        sudo nix-collect-garbage -d 2>/dev/null || true
    fi
    echo "Optimising Nix store..."
    nix store optimise

# Show current generations across OS profiles
generations:
    #!/usr/bin/env bash
    if [[ "$(uname)" == "Darwin" ]]; then
        if command -v darwin-rebuild &> /dev/null; then
            darwin-rebuild --list-generations
        else
            nix-env --list-generations --profile /nix/var/nix/profiles/system
        fi
    elif command -v nixos-rebuild &> /dev/null; then
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    else
        home-manager generations
    fi
