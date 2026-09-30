# Company Laptop Setup

Portable dotfiles for a company-managed Mac — **no installation, no sudo, no admin required**.

This directory extracts the safe, portable parts from the Nix-based personal config and applies them using simple symlinks and `defaults write` commands.

## What's Included

| Category | What it does | Risk |
|:---|:---|:---|
| **Shell aliases** | Guarded aliases (vi→nvim, cat→bat, etc.) | ✅ Zero |
| **Keybindings** | Ctrl-F, Ctrl-W, Ctrl-L, vi-mode bindings | ✅ Zero |
| **FZF integration** | Auto-activates if fzf is installed | ✅ Zero |
| **Environment variables** | EDITOR (cascading), DOWNLOADS, OBSIDIAN | ✅ Zero |
| **Git technical settings** | autocrlf, rebase, defaultBranch (NO identity) | ✅ Zero |
| **App configs** | Neovim, Alacritty, Starship (inert text files) | ✅ Zero |
| **macOS preferences** | Dock, Finder, keyboard repeat, trackpad | ⚠️ MDM may override |

## What's Excluded

- ❌ Nix / nix-darwin / Home Manager
- ❌ Application installation (Homebrew casks, Nixpkgs)
- ❌ Yabai / SKHD (window management)
- ❌ sops-nix secrets
- ❌ Personal Git identity
- ❌ Personal SSH aliases
- ❌ Keyboard modifier remapping

## Quick Start

```bash
# Clone the dotfiles repo (public — no auth needed)
git clone https://github.com/henrynvn09/dotfiles.git ~/dotfiles

# Preview what would happen
cd ~/dotfiles/company
./setup.sh --dry-run

# Run the interactive setup
./setup.sh
```

## Re-running

The script is idempotent — you can re-run it safely. It will:
- Skip symlinks that already point to the right target
- Back up existing files before overwriting (with timestamp)
- Skip the `.zshrc` sourcing block if it already exists

## Updating

```bash
cd ~/dotfiles
git pull
cd company
./setup.sh
```
