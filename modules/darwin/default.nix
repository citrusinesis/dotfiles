{ ... }:

{
  imports = [
    ../shared
    ../shared/fonts.nix

    ./system/base.nix
    ./system/homebrew.nix

    ./system/defaults.nix
    ./system/dock.nix
    ./system/finder.nix
    ./system/input.nix
    ./system/pf
    ./system/security.nix
  ];
}
