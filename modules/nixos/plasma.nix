{ pkgs, ... }:

{
  imports = [ ./graphical.nix ];

  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.bluedevil
  ];
}
