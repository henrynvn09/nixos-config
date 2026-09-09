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
        # Raycast hotkey & vim navigation
        "com.raycast.macos" = {
          raycastGlobalHotkey = "Option-49"; # Option + Space
          navigationCommandStyleIdentifierKey = "vim";
          enforcedInputSourceIDOnOpen = "com.apple.keylayout.US";
        };
      };
    };

    # System activation scripts for hardware settings
    activationScripts.postActivation.text = ''
      # Restore internal MacBook keyboard modifier mapping (Caps Lock -> Cmd, Fn -> Cmd, Cmd -> Opt, Opt -> Disabled)
      defaults -currentHost write -g "com.apple.keyboard.modifiermapping.1452-834-0" -array \
        '{"HIDKeyboardModifierMappingSrc":30064771300,"HIDKeyboardModifierMappingDst":30064771300}' \
        '{"HIDKeyboardModifierMappingSrc":280379760050179,"HIDKeyboardModifierMappingDst":30064771299}' \
        '{"HIDKeyboardModifierMappingSrc":30064771302,"HIDKeyboardModifierMappingDst":30064771072}' \
        '{"HIDKeyboardModifierMappingSrc":1095216660483,"HIDKeyboardModifierMappingDst":30064771303}' \
        '{"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":30064771072}' \
        '{"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771298}' \
        '{"HIDKeyboardModifierMappingSrc":30064771296,"HIDKeyboardModifierMappingDst":30064771296}' \
        '{"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771302}'
    '';
  };
}
