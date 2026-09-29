{ ... }:

{
  # Desktop and input choices specific to this account's machine.
  system.defaults = {
    ".GlobalPreferences" = {
      "com.apple.mouse.scaling" = 1.5;
    };

    NSGlobalDomain = {
      AppleEnableSwipeNavigateWithScrolls = true;
      "com.apple.trackpad.scaling" = 0.875;
    };

    WindowManager = {
      GloballyEnabled = true;
    };

    dock = {
      autohide = false;
    };

    trackpad = {
      Dragging = true;
    };
  };
}
