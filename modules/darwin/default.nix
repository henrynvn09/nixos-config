{ pkgs, ... }:

{
  imports = [
    ./brew.nix
    ./window-manager.nix
  ];

  # Primary user running system activation and user defaults
  system.primaryUser = "henry";

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # macOS system preferences & defaults
  system = {
    stateVersion = 5;

    defaults = {
      # Dock configuration & hot corners
      dock = {
        autohide = true;
        tilesize = 70;
        show-recents = false;
        orientation = "bottom";
        mru-spaces = false;
        magnification = true;
        largesize = 75;
        mineffect = "scale";
        launchanim = false;

        # Explicitly disable all 4 Hot Corners (1 = disabled)
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };

      # Trackpad configuration
      trackpad = {
        Clicking = true;                # Tap to click
        TrackpadThreeFingerDrag = false;
      };

      # Global domain & hidden gestures
      NSGlobalDomain = {
        # Drag windows with Ctrl + Cmd + Click from anywhere inside the window
        NSWindowShouldDragOnGesture = true;

        # Enable spring-loaded folders on drag and drop hover
        "com.apple.springing.enabled" = true;
        "com.apple.springing.delay" = 0.2655597;

        # Scrolling & force click
        "com.apple.swipescrolldirection" = true;
        "com.apple.trackpad.forceClick" = false;

        # Keyboard & typing
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false; # Enable key repeating in vim
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
      };

      # Finder preferences
      finder = {
        FXPreferredViewStyle = "Nlsv";     # Default to list view
        FXDefaultSearchScope = "SCcf";     # Search current folder by default
        FXRemoveOldTrashItems = true;      # Automatically empty trash after 30 days
        AppleShowAllFiles = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = false;
        ShowRemovableMediaOnDesktop = true;
      };

      # macOS Sequoia native window tiling (disable to prevent Yabai conflicts)
      WindowManager = {
        EnableStandardClickToShowDesktop = false;
        EnableTilingByEdgeDrag = false;
        EnableTopTilingByEdgeDrag = false;
        EnableTilingOptionAccelerator = false;
        EnableTiledWindowMargins = false;
        HideDesktop = true;
      };

      # Accessibility settings
      universalaccess = {
        reduceMotion = true;
        mouseDriverCursorSize = 1.613758;
      };

      # Custom preferences for third-party apps
      CustomUserPreferences = {
        # Raycast preferences & keyboard navigation
        "com.raycast.macos" = {
          raycastGlobalHotkey = "Option-49"; # Option + Space
          navigationCommandStyleIdentifierKey = "vim"; # Vim navigation (h/j/k/l)
          enforcedInputSourceIDOnOpen = "com.apple.keylayout.US"; # Automatically switch to US keyboard layout
          raycastShouldFollowSystemAppearance = false; # Force dark mode theme
          raycastCurrentThemeId = "bundled-raycast-dark";
          raycastCurrentThemeIdDarkAppearance = "bundled-raycast-dark";
          raycastCurrentThemeIdLightAppearance = "bundled-raycast-light";
          raycastPreferredWindowMode = "default";
          showGettingStartedLink = false;
          "script-command-mode" = "Compact";
          "script-command-template" = "Bash";
          useHyperKeyIcon = false;
          screenshots_dataSourceEnabled = true;
          snippets_selectedCategoryFilter = "all";
        };
      };
    };

    # System activation scripts for hardware settings
    activationScripts.postActivation.text = ''
      # Apply keyboard modifier mapping live (Swap Command and Option)
      /Users/henry/.local/bin/remap-keys || true

      # Synchronize ByHost GlobalPreferences plist with integer types so macOS System Settings recognizes the mapping
      python3 -c '
import plistlib, glob, os
byhost_files = glob.glob(os.path.expanduser("~/Library/Preferences/ByHost/.GlobalPreferences.*.plist"))
mappings = [
    {"HIDKeyboardModifierMappingSrc": 30064771298, "HIDKeyboardModifierMappingDst": 30064771299},
    {"HIDKeyboardModifierMappingSrc": 30064771299, "HIDKeyboardModifierMappingDst": 30064771298},
    {"HIDKeyboardModifierMappingSrc": 30064771302, "HIDKeyboardModifierMappingDst": 30064771303},
    {"HIDKeyboardModifierMappingSrc": 30064771303, "HIDKeyboardModifierMappingDst": 30064771302}
]
for f in byhost_files:
    try:
        with open(f, "rb") as fp:
            data = plistlib.load(fp)
        data["com.apple.keyboard.modifiermapping.1452-834-0"] = mappings
        with open(f, "wb") as fp:
            plistlib.dump(data, fp)
    except Exception as e:
        pass
' || true
    '';
  };

  # LaunchAgent to ensure hardware modifier remapping applies on login and stays active
  launchd.user.agents.keyboard-remap = {
    serviceConfig = {
      ProgramArguments = [
        "/Users/henry/.local/bin/remap-keys"
      ];
      RunAtLoad = true;
      StartInterval = 30; # Automatic background watchdog to recover if sleep/wake resets HID
    };
  };
}
