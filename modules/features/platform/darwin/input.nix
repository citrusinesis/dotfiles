{ ... }:

let
  hidutilKeyMapping = builtins.toJSON {
    UserKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771129; # 0x700000039 — Caps Lock
        HIDKeyboardModifierMappingDst = 30064771181; # 0x70000006D — F18
      }
    ];
  };
in

{
  system.keyboard = {
    remapCapsLockToEscape = false;
    swapLeftCommandAndLeftAlt = false;
  };

  system.defaults = {
    # Keyboard
    NSGlobalDomain = {
      "com.apple.keyboard.fnState" = true;
      "com.apple.swipescrolldirection" = true;
      AppleKeyboardUIMode = 2;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 3;
    };

    # Trackpad
    trackpad = {
      Clicking = false;
      TrackpadFourFingerHorizSwipeGesture = 0;
      TrackpadFourFingerPinchGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 0;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
      TrackpadThreeFingerHorizSwipeGesture = 2;
      TrackpadThreeFingerVertSwipeGesture = 2;
    };

    CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
      # Disable the default "previous input source" shortcut.
      "60".enabled = false;

      # Bind "Select the next source in the Input Menu" to F18.
      "61" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            79
            0
          ];
        };
      };

      # Disable Spotlight shortcuts to avoid collisions.
      "64".enabled = false;
      "65".enabled = false;

      # Show Notification Center on F13.
      "163" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            105
            0
          ];
        };
      };

      # Switch desktop/space left on Ctrl+Left.
      "79" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            123
            8650752
          ];
        };
      };

      # Switch desktop/space right on Ctrl+Right.
      "81" = {
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            124
            8650752
          ];
        };
      };
    };
  };

  launchd.agents.key-remapping.serviceConfig = {
    Label = "com.local.KeyRemapping";
    ProgramArguments = [
      "/usr/bin/hidutil"
      "property"
      "--set"
      hidutilKeyMapping
    ];
    RunAtLoad = true;
  };
}
