# KDE Plasma 6 Desktop (NixOS)
{ config, pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  services.xserver.enable = true;

  # KDE Plasma 6
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Keymap
  services.xserver.xkb.layout = "us";

  # Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Bluetooth GUI
  environment.systemPackages = with pkgs; [
    kdePackages.bluedevil
  ];
}
