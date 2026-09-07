{ ... }:

{
  imports = [
    ./base.nix
    ./homebrew.nix
    ./launchd.nix
    ./pf
    ./security.nix
  ];

  system.keyboard = {
    remapCapsLockToEscape = false;
    swapLeftCommandAndLeftAlt = false;
  };
}
