{ pkgs, ... }:

{
  imports = [ ./graphical.nix ];

  programs.niri.enable = true;
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  security.pam.services.greetd.enableGnomeKeyring = true;
}
