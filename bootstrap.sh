#!/usr/bin/env bash
set -e

echo "=== Henry's Dotfiles Bootstrap ==="

# 1. Ensure Nix is installed
if ! command -v nix &> /dev/null; then
  echo "Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

# 2. Ensure Homebrew is installed on macOS
if [[ "$(uname)" == "Darwin" ]]; then
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# 3. Apply Configuration
echo "Applying Nix configuration..."
if [[ "$(uname)" == "Darwin" ]]; then
  nix run nix-darwin -- switch --flake .#macbook
elif command -v nixos-rebuild &> /dev/null; then
  sudo nixos-rebuild switch --flake .#nixos
else
  nix run home-manager -- switch --flake .#henry
fi

echo "=== Bootstrap Complete! ==="
