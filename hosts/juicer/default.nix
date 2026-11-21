{
  imports = [
    ../../modules/darwin/base
    ../../modules/darwin/apple-container.nix
    ../../modules/darwin/applications.nix
    ../../modules/darwin/xcode.nix
    ../../modules/system/fonts
    ./nix-store.nix
  ];

  system.defaults = {
    ".GlobalPreferences"."com.apple.mouse.scaling" = 1.5;
    NSGlobalDomain = {
      AppleEnableSwipeNavigateWithScrolls = true;
      "com.apple.trackpad.scaling" = 0.875;
    };
    trackpad.Dragging = true;
  };

  homebrew.brews = [ "mole" ];

  homebrew.casks = [
    "notion"

    "cloudflare-warp"
    "ddpm"
    "firefox"
    "lm-studio"
    "tableplus"
    "utm"
  ];
}
