#!/usr/bin/env python3
"""
Audit installed packages (Homebrew casks & formulae) against ~/dotfiles configuration.
Identifies newly installed or unmanaged packages and detects associated config directories.
"""

import os
import re
import subprocess
import sys
from pathlib import Path

DOTFILES_DIR = Path.home() / "dotfiles"
BREW_NIX = DOTFILES_DIR / "modules/darwin/brew.nix"
PACKAGES_NIX = DOTFILES_DIR / "modules/core/packages.nix"
DOTFILES_NIX = DOTFILES_DIR / "modules/home/dotfiles.nix"


def parse_tracked_packages():
    tracked_brews = set()
    tracked_casks = set()
    tracked_nix = set()
    tracked_configs = set()

    if BREW_NIX.exists():
        content = BREW_NIX.read_text()
        brews_match = re.search(r"brews\s*=\s*\[(.*?)\];", content, re.DOTALL)
        if brews_match:
            tracked_brews = set(re.findall(r'"([^"]+)"', brews_match.group(1)))

        casks_match = re.search(r"casks\s*=\s*\[(.*?)\];", content, re.DOTALL)
        if casks_match:
            tracked_casks = set(re.findall(r'"([^"]+)"', casks_match.group(1)))

    if PACKAGES_NIX.exists():
        content = PACKAGES_NIX.read_text()
        tracked_nix = set(re.findall(r"^\s*([a-zA-Z0-9_\-\.]+)\s*$", content, re.MULTILINE))

    if DOTFILES_NIX.exists():
        content = DOTFILES_NIX.read_text()
        tracked_configs = set(re.findall(r'xdg\.configFile\."([^"]+)"', content))

    return tracked_brews, tracked_casks, tracked_nix, tracked_configs


import shutil

def get_installed_brew():
    installed_brews = set()
    installed_casks = set()

    brew_bin = shutil.which("brew")
    if not brew_bin:
        for candidate in ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]:
            if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
                brew_bin = candidate
                break

    if not brew_bin:
        print("Warning: brew binary not found in PATH or standard locations.", file=sys.stderr)
        return installed_brews, installed_casks

    try:
        res = subprocess.run([brew_bin, "leaves"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        installed_brews = set(line.strip() for line in res.stdout.splitlines() if line.strip())
    except Exception as e:
        print(f"Warning: Failed to fetch brew leaves: {e}", file=sys.stderr)

    try:
        # Pass CASK_OPTS or list directly via Caskroom to avoid tap warnings
        caskroom = Path("/opt/homebrew/Caskroom")
        if not caskroom.exists():
            caskroom = Path("/usr/local/Caskroom")

        if caskroom.exists():
            installed_casks = set(d.name for d in caskroom.iterdir() if d.is_dir() and not d.name.startswith("."))
        else:
            res = subprocess.run([brew_bin, "list", "--cask"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
            installed_casks = set(line.strip() for line in res.stdout.splitlines() if line.strip())
    except Exception as e:
        print(f"Warning: Failed to fetch brew casks: {e}", file=sys.stderr)

    return installed_brews, installed_casks


def find_configs(name):
    found = []
    home = Path.home()
    candidates = [
        home / ".config" / name,
        home / f".{name}rc",
        home / f".{name}",
        home / "Library/Application Support" / name,
    ]
    for c in candidates:
        if c.exists():
            found.append(str(c.relative_to(home)))
    return found


def main():
    tracked_brews, tracked_casks, tracked_nix, tracked_configs = parse_tracked_packages()
    installed_brews, installed_casks = get_installed_brew()

    untracked_casks = sorted(list(installed_casks - tracked_casks))
    untracked_brews = sorted(list(installed_brews - tracked_brews))

    # Separate formulae already in Nixpkgs vs completely untracked
    formulae_in_nix = []
    formulae_untracked = []

    for b in untracked_brews:
        if b in tracked_nix:
            formulae_in_nix.append(b)
        else:
            formulae_untracked.append(b)

    print(f"📦 Audit Report: Installed Packages vs ~/dotfiles")
    print(f"==================================================")
    print(f"• Casks: {len(installed_casks)} installed | {len(tracked_casks)} tracked | {len(untracked_casks)} untracked")
    print(f"• Formulae: {len(installed_brews)} installed | {len(tracked_brews)} tracked in brew | {len(formulae_untracked)} untracked ({len(formulae_in_nix)} redundant in nixpkgs)\n")

    if untracked_casks:
        print("### 🖥️  Untracked GUI Applications (Homebrew Casks)")
        for c in untracked_casks:
            configs = find_configs(c)
            cfg_note = f" *(Config: `~/{configs[0]}`)*" if configs else ""
            print(f"- [ ] **{c}**{cfg_note}")
        print()

    if formulae_untracked:
        print("### ⚙️  Untracked CLI Tools (Homebrew Formulae)")
        for b in formulae_untracked:
            configs = find_configs(b)
            cfg_note = f" *(Config: `~/{configs[0]}`)*" if configs else ""
            print(f"- [ ] **{b}**{cfg_note}")
        print()

    if formulae_in_nix:
        print("### 🔄 Formulae Redundant with Nixpkgs (Already in modules/core/packages.nix)")
        print(", ".join(f"`{f}`" for f in formulae_in_nix))
        print()


if __name__ == "__main__":
    main()
