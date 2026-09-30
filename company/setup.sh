#!/bin/zsh
# ==============================================================================
# company/setup.sh — Company Laptop Dotfiles Setup
# ==============================================================================
#
# Configures shell, Git, and macOS preferences for a company-managed Mac.
# Does NOT install any software or require sudo/admin access.
#
# Usage:
#   ./setup.sh              # Interactive mode (confirms each step)
#   ./setup.sh --dry-run    # Preview all changes without applying
#
# Source repository: ~/dotfiles (https://github.com/henrynvn09/dotfiles)
# ==============================================================================

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
COMPANY_DIR="$SCRIPT_DIR"
CONFIG_DIR="$DOTFILES_DIR/config"
COMPANY_STATE_DIR="$HOME/.config/dotfiles-company"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# ── Colors ───────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ── Helpers ──────────────────────────────────────────────────────
info()    { echo -e "${BLUE}▸${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
header()  { echo -e "\n${BOLD}${CYAN}$1${NC}"; echo -e "${DIM}$(printf '%.0s─' {1..60})${NC}"; }
dry()     { echo -e "  ${DIM}[DRY RUN]${NC} $1"; }

confirm() {
  if $DRY_RUN; then
    return 0
  fi
  local prompt="$1"
  echo -en "${BOLD}$prompt${NC} ${DIM}[Y/n]:${NC} "
  read -r response
  [[ -z "$response" || "$response" =~ ^[Yy] ]]
}

safe_symlink() {
  local src="$1"
  local dst="$2"

  if $DRY_RUN; then
    dry "Would symlink: $src → $dst"
    return
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$dst")"

  # Back up existing file if it's not already a symlink to our source
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
    warn "Backed up existing: $dst"
  elif [ -L "$dst" ]; then
    rm "$dst"
  fi

  ln -s "$src" "$dst"
  success "Linked: $(basename "$src") → $dst"
}

safe_copy() {
  local src="$1"
  local dst="$2"

  if $DRY_RUN; then
    dry "Would copy: $src → $dst"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
    warn "Backed up existing: $dst"
  fi

  cp "$src" "$dst"
  success "Copied: $(basename "$src") → $dst"
}

# ── Banner ───────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}🔧 Company Laptop Dotfiles Setup${NC}"
echo -e "${DIM}══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "This script configures your shell, Git, and macOS preferences."
echo -e "It ${BOLD}will NOT${NC} install any software or require admin access."
echo ""

if $DRY_RUN; then
  echo -e "${YELLOW}${BOLD}🔍 DRY RUN MODE — No changes will be made${NC}"
  echo ""
fi

# ══════════════════════════════════════════════════════════════════
# Step 1: Shell Configuration
# ══════════════════════════════════════════════════════════════════
header "Step 1/5: Shell Configuration"
echo ""
info "Aliases with tool guards (vi→nvim, cat→bat, etc.)"
info "Zsh keybindings (Ctrl-F, Ctrl-W, Ctrl-L, etc.)"
info "FZF fuzzy finder integration (auto-activates if fzf exists)"
echo ""

if confirm "Apply shell configuration?"; then
  # Ensure ~/.config/zsh/ exists
  mkdir -p "$HOME/.config/zsh" 2>/dev/null || true

  safe_symlink "$COMPANY_DIR/shell/aliases.zsh" "$HOME/.config/zsh/company-aliases.zsh"
  safe_symlink "$COMPANY_DIR/shell/keybindings.zsh" "$HOME/.config/zsh/company-keybindings.zsh"
  safe_symlink "$COMPANY_DIR/shell/fzf.zsh" "$HOME/.config/zsh/company-fzf.zsh"
  safe_symlink "$COMPANY_DIR/shell/env.zsh" "$HOME/.config/zsh/company-env.zsh"

  # Add sourcing to .zshrc if not already present
  ZSHRC="$HOME/.zshrc"
  MARKER="# >>> dotfiles-company shell config >>>"

  if $DRY_RUN; then
    if ! grep -q "$MARKER" "$ZSHRC" 2>/dev/null; then
      dry "Would add sourcing block to $ZSHRC"
    else
      dry "Sourcing block already exists in $ZSHRC"
    fi
  else
    if ! grep -q "$MARKER" "$ZSHRC" 2>/dev/null; then
      cat >> "$ZSHRC" << 'SHELL_BLOCK'

# >>> dotfiles-company shell config >>>
# Managed by ~/dotfiles/company/setup.sh — do not edit this block
for _cf in "$HOME/.config/zsh"/company-*.zsh(N); do
  source "$_cf"
done
unset _cf
# <<< dotfiles-company shell config <<<
SHELL_BLOCK
      success "Added sourcing block to ~/.zshrc"
    else
      info "Sourcing block already exists in ~/.zshrc — skipping"
    fi
  fi
else
  warn "Skipped shell configuration"
fi

# ══════════════════════════════════════════════════════════════════
# Step 2: Git Technical Settings
# ══════════════════════════════════════════════════════════════════
header "Step 2/5: Git Technical Settings"
echo ""
info "core.autocrlf = input"
info "core.symlinks = true"
info "init.defaultBranch = main"
info "pull.rebase = true"
info "push.default = current"
echo ""
echo -e "  ${DIM}⚠ NO personal identity (user.name/email) will be set${NC}"
echo ""

if confirm "Apply Git technical settings?"; then
  safe_copy "$COMPANY_DIR/git/gitconfig-technical" "$HOME/.gitconfig-dotfiles"
  safe_copy "$COMPANY_DIR/git/gitignore-global" "$HOME/.gitignore-global"

  if $DRY_RUN; then
    dry "Would add [include] and [core].excludesFile to ~/.gitconfig"
  else
    # Add include to ~/.gitconfig if not already present
    if ! git config --global --get include.path 2>/dev/null | grep -q ".gitconfig-dotfiles"; then
      git config --global include.path "$HOME/.gitconfig-dotfiles"
      success "Added include.path to ~/.gitconfig"
    else
      info "Git include already configured — skipping"
    fi

    # Set global gitignore
    git config --global core.excludesFile "$HOME/.gitignore-global"
    success "Set global gitignore"
  fi
else
  warn "Skipped Git configuration"
fi

# ══════════════════════════════════════════════════════════════════
# Step 3: App Configs (inert symlinks)
# ══════════════════════════════════════════════════════════════════
header "Step 3/5: App Configs (Neovim, Alacritty, Starship)"
echo ""
info "These are text files — they do nothing if the app isn't installed"
info "Symlinking from shared config/ directory in the dotfiles repo"
echo ""

# List what's available
for app_dir in nvim alacritty starship; do
  if [ -d "$CONFIG_DIR/$app_dir" ] || [ -f "$CONFIG_DIR/$app_dir/starship.toml" ]; then
    echo -e "  ${GREEN}●${NC} config/$app_dir"
  fi
done
echo ""

if confirm "Apply app config symlinks?"; then
  # Neovim
  if [ -d "$CONFIG_DIR/nvim" ]; then
    safe_symlink "$CONFIG_DIR/nvim" "$HOME/.config/nvim"
  fi

  # Alacritty
  if [ -d "$CONFIG_DIR/alacritty" ]; then
    safe_symlink "$CONFIG_DIR/alacritty" "$HOME/.config/alacritty"
  fi

  # Starship
  if [ -f "$CONFIG_DIR/starship/starship.toml" ]; then
    safe_symlink "$CONFIG_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
  fi

  # Firefox userChrome (if Firefox exists and config is present)
  if [ -d "$CONFIG_DIR/firefox/chrome" ]; then
    FIREFOX_DIR="$HOME/Library/Application Support/Firefox/Profiles"
    if [ -d "$FIREFOX_DIR" ]; then
      for profile in "$FIREFOX_DIR"/*.default*; do
        if [ -d "$profile" ]; then
          if $DRY_RUN; then
            dry "Would link Firefox userChrome to $profile/chrome/"
          else
            mkdir -p "$profile/chrome"
            ln -sfn "$CONFIG_DIR/firefox/chrome/userChrome.css" "$profile/chrome/userChrome.css" 2>/dev/null || true
            ln -sfn "$CONFIG_DIR/firefox/chrome/userContent.css" "$profile/chrome/userContent.css" 2>/dev/null || true
            success "Linked Firefox userChrome to $(basename "$profile")"
          fi
        fi
      done
    fi
  fi
else
  warn "Skipped app configs"
fi

# ══════════════════════════════════════════════════════════════════
# Step 4: Environment Variables (Interactive)
# ══════════════════════════════════════════════════════════════════
header "Step 4/5: Environment Variables"
echo ""
info "Configure custom paths for this machine"
info "Settings saved to ~/.config/dotfiles-company/paths.env"
echo ""

if confirm "Configure environment variable paths?"; then
  if $DRY_RUN; then
    dry "Would prompt for DOWNLOADS, OBSIDIAN paths"
    dry "Would save to $COMPANY_STATE_DIR/paths.env"
  else
    mkdir -p "$COMPANY_STATE_DIR"
    PATHS_FILE="$COMPANY_STATE_DIR/paths.env"

    # DOWNLOADS
    echo -en "${BOLD}  DOWNLOADS path${NC} ${DIM}[$HOME/Downloads]:${NC} "
    read -r downloads_path
    downloads_path="${downloads_path:-$HOME/Downloads}"

    # OBSIDIAN
    echo -en "${BOLD}  OBSIDIAN vault path${NC} ${DIM}[leave blank to skip]:${NC} "
    read -r obsidian_path

    # OBSIDIAN_CURRENT_CLASS
    obsidian_class_path=""
    if [ -n "$obsidian_path" ]; then
      echo -en "${BOLD}  OBSIDIAN_CURRENT_CLASS path${NC} ${DIM}[leave blank to skip]:${NC} "
      read -r obsidian_class_path
    fi

    # Write paths.env
    {
      echo "# Generated by ~/dotfiles/company/setup.sh on $(date)"
      echo "export DOWNLOADS=\"$downloads_path\""
      [ -n "$obsidian_path" ] && echo "export OBSIDIAN=\"$obsidian_path\""
      [ -n "$obsidian_class_path" ] && echo "export OBSIDIAN_CURRENT_CLASS=\"$obsidian_class_path\""
    } > "$PATHS_FILE"

    success "Saved to $PATHS_FILE"
  fi
else
  warn "Skipped environment variables"
fi

# ══════════════════════════════════════════════════════════════════
# Step 5: macOS Preferences
# ══════════════════════════════════════════════════════════════════
header "Step 5/5: macOS Preferences"
echo ""
info "Dock: autohide, 70px icons, hide recents, disable hot corners"
info "Keyboard: fast repeat, disable press-and-hold (for vim)"
info "Finder: list view, show path bar, search current folder"
info "Trackpad: tap to click"
info "Accessibility: reduce motion"
echo ""
echo -e "  ${DIM}⚠ MDM may override some of these settings${NC}"
echo ""

if confirm "Apply macOS preferences?"; then
  if $DRY_RUN; then
    zsh "$COMPANY_DIR/macos/defaults.sh" --dry-run
  else
    zsh "$COMPANY_DIR/macos/defaults.sh"
  fi
else
  warn "Skipped macOS preferences"
fi

# ══════════════════════════════════════════════════════════════════
# Summary & Suggestions
# ══════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if $DRY_RUN; then
  echo -e "${BOLD}🔍 DRY RUN COMPLETE — No changes were made${NC}"
  echo -e "${DIM}Run without --dry-run to apply changes.${NC}"
else
  echo -e "${BOLD}${GREEN}✅ Company laptop setup complete!${NC}"
  echo ""
  echo -e "${DIM}To apply shell changes in your current terminal:${NC}"
  echo -e "  ${BOLD}source ~/.zshrc${NC}"
fi

echo ""
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📋 OPTIONAL: Tools you might want to install${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "If your company allows it, these tools from your personal"
echo -e "setup would enhance your workflow. Check with IT first."
echo ""
echo -e "${BOLD}Essential CLI:${NC}"
echo -e "  brew install fzf ripgrep fd bat jq eza tldr tree"
echo ""
echo -e "${BOLD}Editor:${NC}"
echo -e "  brew install neovim"
echo ""
echo -e "${BOLD}Prompt:${NC}"
echo -e "  brew install starship"
echo -e "  ${DIM}# Then add to ~/.zshrc: eval \"\$(starship init zsh)\"${NC}"
echo ""
echo -e "${BOLD}Terminal:${NC}"
echo -e "  brew install --cask alacritty"
echo ""
echo -e "${BOLD}Utilities:${NC}"
echo -e "  brew install trash-cli thefuck uv curl wget"
echo ""
echo -e "${BOLD}Fonts (requires Homebrew):${NC}"
echo -e "  brew install --cask font-jetbrains-mono-nerd-font"
echo -e "  brew install --cask font-fira-code"
echo -e "  brew install --cask font-caskaydia-cove-nerd-font"
echo -e "  brew install --cask font-0xproto-nerd-font"
echo -e "  brew install --cask font-atkinson-hyperlegible"
echo -e "  brew install --cask font-mononoki-nerd-font"
echo -e "  brew install --cask font-sauce-code-pro-nerd-font"
echo ""
echo -e "${YELLOW}⚠  Check with your IT department before installing anything.${NC}"
echo -e "${DIM}   Some companies provide a Self Service app or approved software catalog.${NC}"
echo ""
