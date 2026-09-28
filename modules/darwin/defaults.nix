{ lib, ... }:

{
  # Shared preferences; account modules may override individual keys.
  system.defaults = {
    CustomUserPreferences = {
      ".GlobalPreferences" = {
        AppleLanguages = lib.mkDefault [
          "en-KR"
          "ko-KR"
        ];
        AppleLocale = lib.mkDefault "en_KR";
        WebKitDeveloperExtras = lib.mkDefault true;
      };

      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = lib.mkDefault false;
      };

      "com.apple.ImageCapture" = {
        disableHotPlug = lib.mkDefault true;
      };

      "com.apple.widgets" = {
        widgetAppearance = lib.mkDefault 0;
      };
    };

    NSGlobalDomain = {
      AppleICUForce24HourTime = lib.mkDefault true;
      AppleInterfaceStyleSwitchesAutomatically = lib.mkDefault true;
      AppleKeyboardUIMode = lib.mkDefault 2;
      AppleMeasurementUnits = lib.mkDefault "Centimeters";
      AppleMetricUnits = lib.mkDefault 1;
      ApplePressAndHoldEnabled = lib.mkDefault false;
      AppleShowScrollBars = lib.mkDefault "WhenScrolling";
      AppleSpacesSwitchOnActivate = lib.mkDefault true;
      AppleTemperatureUnit = lib.mkDefault "Celsius";
      AppleWindowTabbingMode = lib.mkDefault "always";
      InitialKeyRepeat = lib.mkDefault 15;
      KeyRepeat = lib.mkDefault 3;
      NSAutomaticCapitalizationEnabled = lib.mkDefault false;
      NSAutomaticDashSubstitutionEnabled = lib.mkDefault false;
      NSAutomaticInlinePredictionEnabled = lib.mkDefault false;
      NSAutomaticPeriodSubstitutionEnabled = lib.mkDefault false;
      NSAutomaticQuoteSubstitutionEnabled = lib.mkDefault false;
      NSAutomaticSpellingCorrectionEnabled = lib.mkDefault false;
      NSDocumentSaveNewDocumentsToCloud = lib.mkDefault false;
      NSNavPanelExpandedStateForSaveMode = lib.mkDefault true;
      NSNavPanelExpandedStateForSaveMode2 = lib.mkDefault true;
      NSWindowShouldDragOnGesture = lib.mkDefault true;
      _HIHideMenuBar = lib.mkDefault false;
      "com.apple.keyboard.fnState" = lib.mkDefault true;
      "com.apple.sound.beep.feedback" = lib.mkDefault 0;
      "com.apple.swipescrolldirection" = lib.mkDefault true;
    };

    SoftwareUpdate = {
      AutomaticallyInstallMacOSUpdates = lib.mkDefault true;
    };

    controlcenter = {
      BatteryShowPercentage = lib.mkDefault true;
    };

    menuExtraClock = {
      ShowAMPM = lib.mkDefault false;
      ShowDate = lib.mkDefault 1;
    };

    screencapture = {
      type = lib.mkDefault "png";
    };

    screensaver = {
      askForPassword = lib.mkDefault true;
      askForPasswordDelay = lib.mkDefault 0;
    };
  };
}
