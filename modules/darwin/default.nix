{
  imports = [
    ../system/core
    ./base.nix
    ./homebrew.nix
    ./launchd.nix
    ./pf
    ./security.nix
    ./defaults.nix
    ./dock.nix
    ./finder.nix
    ./input.nix
  ];

  system.keyboard = {
    remapCapsLockToEscape = false;
    swapLeftCommandAndLeftAlt = false;
  };
}
