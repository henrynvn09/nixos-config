# Henry's Dotfiles (Nix Flake)

A declarative, reproducible configuration for **macOS (nix-darwin)** and **Linux (NixOS / Home Manager)**.

---

## 🗂 Architecture

```
~/dotfiles/
├── flake.nix                  # Unified entrypoint (inputs, outputs, host definitions)
├── Justfile                   # Command runner (just switch, just update, etc.)
├── bootstrap.sh               # 1-command fresh machine setup script
├── .sops.yaml                 # SOPS / age encryption configuration
│
├── hosts/                     # Machine-specific entrypoints
│   ├── macbook/               # macOS primary machine (aarch64-darwin)
│   └── nixos/                 # Linux / NixOS template (x86_64-linux)
│
├── modules/
│   ├── core/                  # Universal cross-platform settings (git, packages, shell)
│   ├── darwin/                # macOS settings (defaults, Homebrew casks, yabai/skhd)
│   └── home/                  # Home Manager dotfiles and user environment
│
├── config/                    # Out-of-store live editable dotfiles
│   ├── nvim/                  # Neovim (Lazy.nvim)
│   ├── alacritty/             # Alacritty terminal
│   ├── yabai/                 # Window manager
│   ├── skhd/                  # Hotkey daemon
│   └── starship/              # Prompt theme
│
└── secrets/                   # Encrypted secrets via sops-nix
```

---

## ⚡ Quick Commands (`just`)

This repository uses [`just`](https://github.com/casey/just) to streamline common actions:

| Command | Action |
| :--- | :--- |
| `just switch` | Rebuild and apply configuration to current machine |
| `just check` | Check flake syntax and inputs without building |
| `just update` | Update all flake lockfile dependencies |
| `just gc` | Garbage collect old Nix generations |
| `just generations` | List history of system generations |

---

## 🚀 Bootstrapping a New Machine

On any fresh Mac or Linux machine:

```bash
git clone https://github.com/henrynvn09/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

---

## ✏️ Modifying Dotfiles

Active configurations in `~/dotfiles/config/` (such as `nvim`, `alacritty`, `yabai`, `skhd`) are linked using **out-of-store symlinks**. 
- You can edit them live and see changes immediately without running a rebuild.
- To commit your changes, simply run `git commit` inside `~/dotfiles`.
