#!/usr/bin/env bash
set -euo pipefail

echo "=== Starting Henry's Dotfiles Bootstrap ==="

# 1. Resolve repository directory regardless of where the script was launched from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Ensure repo is located or symlinked at ~/dotfiles
if [[ "$SCRIPT_DIR" != "$HOME/dotfiles" ]]; then
  echo "Notice: Repository is at '$SCRIPT_DIR'. Ensuring '$HOME/dotfiles' symlink exists..."
  if [ ! -e "$HOME/dotfiles" ]; then
    ln -s "$SCRIPT_DIR" "$HOME/dotfiles"
  fi
fi

# 2. Ensure Nix is installed
if ! command -v nix &> /dev/null; then
  echo "Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

NIX_BIN="$(command -v nix || echo "/nix/var/nix/profiles/default/bin/nix")"
NIX_RUN="$NIX_BIN --extra-experimental-features 'nix-command flakes' run"

# 3. Handle macOS-specific bootstrapping (Homebrew & /etc/zshrc backup)
if [[ "$(uname)" == "Darwin" ]]; then
  # Safely backup factory /etc/zshrc and /etc/bashrc before nix-darwin switch
  # (nix-darwin refuses to overwrite existing unmanaged /etc/zshrc files)
  for etc_file in /etc/zshrc /etc/bashrc; do
    if [ -f "$etc_file" ] && [ ! -L "$etc_file" ]; then
      echo "Backing up existing $etc_file to ${etc_file}.before-nix-darwin..."
      sudo mv "$etc_file" "${etc_file}.before-nix-darwin"
    fi
  done

  # Ensure Homebrew is installed
  if ! command -v brew &> /dev/null && [ ! -f /opt/homebrew/bin/brew ] && [ ! -f /usr/local/bin/brew ]; then
    echo "Installing Homebrew (non-interactive)..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Add brew to PATH for current session
  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# 4. Apply Nix Configuration
echo "Applying Nix configuration from $SCRIPT_DIR..."
if [[ "$(uname)" == "Darwin" ]]; then
  $NIX_RUN nix-darwin -- switch --flake "${SCRIPT_DIR}#macbook"
elif command -v nixos-rebuild &> /dev/null; then
  sudo nixos-rebuild switch --flake "${SCRIPT_DIR}#nixos"
else
  $NIX_RUN home-manager -- switch --flake "${SCRIPT_DIR}#henry" -b backup
fi

echo "=== Bootstrap Complete! ==="
