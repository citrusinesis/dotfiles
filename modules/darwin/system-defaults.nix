{ flake, ... }:

let
  inherit (flake.inputs) self;
  personal = import (self + /personal.nix);
  username = personal.user.username;
  hidutilKeyMapping = builtins.toJSON {
    UserKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771303;
        HIDKeyboardModifierMappingDst = 30064771181;
      }
      {
        HIDKeyboardModifierMappingSrc = 30064771302;
        HIDKeyboardModifierMappingDst = 1095216660483;
      }
    ];
  };
in

{
  system = {
    primaryUser = username;
    stateVersion = 5;

    keyboard = {
      enableKeyMapping = true;
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
          "60".enabled = false;
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
          "64".enabled = false;
          "65".enabled = false;
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
