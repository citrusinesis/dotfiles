{ lib, ... }:

{
  # Shared preferences; account modules may override individual keys.
  system.defaults = {
    CustomUserPreferences = {
      "com.apple.HIToolbox" = {
        AppleEnabledInputSources = lib.mkDefault [
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 252;
            "KeyboardLayout Name" = "ABC";
          }
          {
            "Bundle ID" = "com.apple.inputmethod.Korean";
            "Input Mode" = "com.apple.inputmethod.Korean.2SetKorean";
            InputSourceKind = "Input Mode";
          }
          {
            "Bundle ID" = "com.apple.inputmethod.Korean";
            InputSourceKind = "Keyboard Input Method";
          }
          {
            "Bundle ID" = "com.apple.CharacterPaletteIM";
            InputSourceKind = "Non Keyboard Input Method";
          }
        ];
      };

      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Show Notification Center on F13.
          "163" = {
            enabled = lib.mkDefault true;
            value = {
              parameters = lib.mkDefault [
                65535
                105
                0
              ];
              type = lib.mkDefault "standard";
            };
          };

          # Disable the previous input source shortcut.
          "60" = {
            enabled = lib.mkDefault false;
          };

          # Select the next input source on F18 (mapped from Caps Lock).
          "61" = {
            enabled = lib.mkDefault true;
            value = {
              parameters = lib.mkDefault [
                65535
                79
                0
              ];
              type = lib.mkDefault "standard";
            };
          };

          # Disable Spotlight shortcuts to avoid collisions.
          "64" = {
            enabled = lib.mkDefault false;
          };

          "65" = {
            enabled = lib.mkDefault false;
          };

          # Switch to the space on the left with Ctrl+Left.
          "79" = {
            enabled = lib.mkDefault true;
            value = {
              parameters = lib.mkDefault [
                65535
                123
                8650752
              ];
              type = lib.mkDefault "standard";
            };
          };

          # Switch to the space on the right with Ctrl+Right.
          "81" = {
            enabled = lib.mkDefault true;
            value = {
              parameters = lib.mkDefault [
                65535
                124
                8650752
              ];
              type = lib.mkDefault "standard";
            };
          };
        };
      };
    };

    hitoolbox = {
      AppleFnUsageType = lib.mkDefault "Show Emoji & Symbols";
    };

    trackpad = {
      Clicking = lib.mkDefault false;
      TrackpadFourFingerHorizSwipeGesture = lib.mkDefault 0;
      TrackpadFourFingerPinchGesture = lib.mkDefault 2;
      TrackpadFourFingerVertSwipeGesture = lib.mkDefault 0;
      TrackpadRightClick = lib.mkDefault true;
      TrackpadThreeFingerDrag = lib.mkDefault false;
      TrackpadThreeFingerHorizSwipeGesture = lib.mkDefault 2;
      TrackpadThreeFingerVertSwipeGesture = lib.mkDefault 2;
    };
  };
}
