{ ... }:

{
  imports = [
    ../shared

    ./base.nix
    ./container-runtime.nix
    ./homebrew.nix

    ./system/defaults.nix
    ./system/dock.nix
    ./system/finder.nix
    ./system/input.nix
    ./system/pf.nix
    ./system/security.nix
  ];
}
