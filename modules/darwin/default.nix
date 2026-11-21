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

  pf = {
    screen-sharing = {
      enable = true;
      high-performance = true;
    };
    ssh.enable = true;
  };

  system.keyboard = {
    remapCapsLockToEscape = false;
    swapLeftCommandAndLeftAlt = false;
  };
}
