# Justfile - Command runner for Nix dotfiles

default:
    @just --list

# Switch system configuration (auto-detects macOS vs Linux)
switch:
    #!/usr/bin/env bash
    if [[ "$(uname)" == "Darwin" ]]; then
        if command -v darwin-rebuild &> /dev/null; then
            darwin-rebuild switch --flake .#macbook
        else
            nix run nix-darwin -- switch --flake .#macbook
        fi
    elif command -v nixos-rebuild &> /dev/null; then
        sudo nixos-rebuild switch --flake .#nixos
    else
        nix run home-manager -- switch --flake .#henry
    fi

# Check flake syntax and inputs
check:
    nix flake check

# Update all flake inputs
update:
    nix flake update

# Garbage collect old generations to free disk space
gc:
    nix-collect-garbage -d

# Show current generations
generations:
    #!/usr/bin/env bash
    if [[ "$(uname)" == "Darwin" ]]; then
        darwin-rebuild --list-generations
    elif command -v nixos-rebuild &> /dev/null; then
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    else
        home-manager generations
    fi
