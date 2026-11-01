{ pkgs, ... }:

# System side of the Hyprland session; its configuration lives in modules/home/hyprland.nix.
{
  imports = [ ./graphical.nix ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Installs the PAM service hyprlock authenticates against.
  programs.hyprlock.enable = true;

  # Secret storage for applications outside Plasma, where KWallet is not running.
  services.gnome.gnome-keyring.enable = true;

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
