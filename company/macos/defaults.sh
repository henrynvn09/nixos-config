#!/bin/zsh
# company/macos/defaults.sh — macOS system preferences (user-level)
# Source: modules/darwin/default.nix → system.defaults
#
# These are standard `defaults write` commands — normal user-level
# macOS operations. No sudo required. No software installed.
#
# ⚠️  On MDM-managed Macs, IT configuration profiles may silently
#     override some of these settings. They won't cause errors,
#     but may revert after the next MDM check-in.
#
# Usage:
#   ./defaults.sh              # Apply all
#   ./defaults.sh --dry-run    # Preview only

set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

run_default() {
  if $DRY_RUN; then
    echo "  [DRY RUN] defaults write $*"
  else
    defaults write "$@"
  fi
}

echo ""
echo "── Dock ──────────────────────────────────────────────────"
run_default com.apple.dock autohide -bool true
run_default com.apple.dock tilesize -integer 70
run_default com.apple.dock show-recents -bool false
run_default com.apple.dock orientation -string "bottom"
run_default com.apple.dock mru-spaces -bool false
run_default com.apple.dock magnification -bool true
run_default com.apple.dock largesize -integer 75
run_default com.apple.dock mineffect -string "scale"
run_default com.apple.dock launchanim -bool false
# Disable all Hot Corners (1 = disabled)
run_default com.apple.dock wvous-bl-corner -int 1
run_default com.apple.dock wvous-br-corner -int 1
run_default com.apple.dock wvous-tl-corner -int 1
run_default com.apple.dock wvous-tr-corner -int 1

echo ""
echo "── Trackpad (may be MDM-locked) ────────────────────────"
run_default com.apple.AppleMultitouchTrackpad Clicking -bool true
run_default com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false

echo ""
echo "── Keyboard & Typing ────────────────────────────────────"
run_default NSGlobalDomain AppleShowAllExtensions -bool true
run_default NSGlobalDomain ApplePressAndHoldEnabled -bool false   # Key repeat (vim)
run_default NSGlobalDomain KeyRepeat -int 2
run_default NSGlobalDomain InitialKeyRepeat -int 15
run_default NSGlobalDomain NSWindowShouldDragOnGesture -bool true  # Ctrl+Cmd drag windows

echo ""
echo "── Scrolling & Force Click ──────────────────────────────"
run_default NSGlobalDomain "com.apple.swipescrolldirection" -bool true  # Natural scrolling
run_default NSGlobalDomain "com.apple.trackpad.forceClick" -bool false

echo ""
echo "── Spring-loaded folders ────────────────────────────────"
run_default NSGlobalDomain "com.apple.springing.enabled" -bool true
run_default NSGlobalDomain "com.apple.springing.delay" -float 0.2655597

echo ""
echo "── Finder ───────────────────────────────────────────────"
run_default com.apple.finder FXPreferredViewStyle -string "Nlsv"      # List view
run_default com.apple.finder FXDefaultSearchScope -string "SCcf"      # Search current folder
run_default com.apple.finder FXRemoveOldTrashItems -bool true         # Auto-empty trash (30d)
run_default com.apple.finder AppleShowAllFiles -bool true
run_default com.apple.finder ShowPathbar -bool true
run_default com.apple.finder ShowStatusBar -bool true
run_default com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
run_default com.apple.finder ShowHardDrivesOnDesktop -bool false
run_default com.apple.finder ShowRemovableMediaOnDesktop -bool true

echo ""
echo "── Accessibility ────────────────────────────────────────"
run_default com.apple.universalaccess reduceMotion -bool true

echo ""
echo "── EXCLUDED from company config ─────────────────────────"
echo "  • WindowManager tiling settings (Yabai-specific)"
echo "  • Keyboard modifier remapping (hardware-specific)"
echo "  • Raycast preferences (requires Raycast installation)"
echo "  • LaunchAgent for remap-keys (personal hardware)"

# Restart affected apps to apply changes
if ! $DRY_RUN; then
  echo ""
  echo "── Restarting affected apps... ────────────────────────"
  killall Dock 2>/dev/null || true
  killall Finder 2>/dev/null || true
  echo "  ✅ Done"
fi
