{ ... }:

{
  imports = [
    ./minimal.nix
    
    ./system/desktop.nix
    ./system/audio.nix
    ./system/networking.nix
    ./system/i18n.nix
    ./system/power.nix
  ];
}
