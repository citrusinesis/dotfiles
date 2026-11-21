{
  imports = [
    ../../modules/darwin/base
    ../../modules/darwin/apple-container.nix
    ../../modules/system/fonts
  ];

  system.defaults = {
    ".GlobalPreferences"."com.apple.mouse.scaling" = 0.6875;
    NSGlobalDomain = {
      AppleEnableSwipeNavigateWithScrolls = false;
      "com.apple.trackpad.scaling" = 1.0;
    };
    trackpad.Dragging = false;
  };

  power = {
    sleep = {
      computer = "never";
      display = "never";
      harddisk = "never";

      allowSleepByPowerButton = true;
    };

    restartAfterFreeze = true;
    restartAfterPowerFailure = true;
  };

  homebrew.casks = [ "mongodb-compass" ];
}
