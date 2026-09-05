{ ... }:

{
  system.defaults = {
    screencapture.type = "png";

    # Global Preferences
    NSGlobalDomain = {
      # Autocorrect — all off
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      # Appearance & UI
      "com.apple.sound.beep.feedback" = 0;
      _HIHideMenuBar = false;
      AppleInterfaceStyleSwitchesAutomatically = true;
      AppleShowScrollBars = "WhenScrolling";
      AppleWindowTabbingMode = "always";
      NSWindowShouldDragOnGesture = true;

      # Dialogs
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # Region & units
      AppleICUForce24HourTime = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
    };

    # Extras (no native nix-darwin option)
    CustomUserPreferences = {
      NSGlobalDomain.WebKitDeveloperExtras = true;
      "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
      "com.apple.ImageCapture".disableHotPlug = true;
      "com.apple.widgets".widgetAppearance = 0;
    };
  };
}
