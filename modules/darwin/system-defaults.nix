{ flake, ... }:

let
  inherit (flake.inputs) self;
  personal = import (self + /personal.nix);
  username = personal.user.username;

  # hidutil uses USB HID usage codes.
  # Caps Lock = 0x700000039
  # F18       = 0x70000006D
  hidutilKeyMapping = builtins.toJSON {
    UserKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771129;
        HIDKeyboardModifierMappingDst = 30064771181;
      }
    ];
  };
in

{
  system = {
    primaryUser = username;
    stateVersion = 5;

    keyboard = {
      remapCapsLockToEscape = false;
      swapLeftCommandAndLeftAlt = false;
    };

    defaults = {
      dock = {
        autohide = false;
        show-recents = false;
        static-only = true;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      trackpad = {
        Clicking = false;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = true;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.keyboard.fnState" = true;
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 3;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = false;
      };

      CustomUserPreferences = {
        ".GlobalPreferences".AppleSpacesSwitchOnActivate = true;
        NSGlobalDomain.WebKitDeveloperExtras = true;

        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          FXDefaultSearchScope = "SCcf";
        };

        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.apple.screensaver" = {
          askForPassword = 1;
          askForPasswordDelay = 0;
        };

        "com.apple.screencapture" = {
          location = "~/Desktop";
          type = "png";
        };

        "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
        "com.apple.ImageCapture".disableHotPlug = true;

        "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
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

      loginwindow.GuestEnabled = false;
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

  security.pam.services.sudo_local.touchIdAuth = true;
}
