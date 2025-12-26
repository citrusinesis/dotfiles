# KDE Plasma 6 Desktop (NixOS)
{ config, pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb.layout = "us";

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    kdePackages.bluedevil
  ];
}
