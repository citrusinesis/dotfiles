{ ... }:

{
  # Desktop and input choices specific to this account's machine.
  system.defaults = {
    ".GlobalPreferences" = {
      "com.apple.mouse.scaling" = 0.6875;
    };

    NSGlobalDomain = {
      AppleEnableSwipeNavigateWithScrolls = false;
      "com.apple.trackpad.scaling" = 1.0;
    };

    WindowManager = {
      GloballyEnabled = true;
    };

    dock = {
      autohide = false;
    };

    trackpad = {
      Dragging = false;
    };
  };
}
