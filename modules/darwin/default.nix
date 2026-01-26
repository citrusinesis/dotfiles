{ ... }:

{
  imports = [
    ../shared/nix.nix
    ../shared/fonts.nix
    
    ./base.nix
    ./homebrew.nix
    ./system-defaults.nix
  ];
}
