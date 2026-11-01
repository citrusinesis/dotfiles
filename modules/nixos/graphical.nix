{ ... }:

# Shared by every desktop session module (plasma, hyprland).
{
  imports = [
    ./audio.nix
    ./networking.nix
    ./i18n.nix
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
