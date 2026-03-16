{ ... }:

{
  imports = [
    ../shared/nix.nix
    ../shared/fonts.nix

    ./base.nix
    ./homebrew.nix

    ./system/defaults.nix
    ./system/dock.nix
    ./system/finder.nix
    ./system/input.nix
    ./system/security.nix
  ];
}
