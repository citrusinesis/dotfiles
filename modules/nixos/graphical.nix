{ ... }:

# Shared graphics-session services; the host selects its compositor and greeter.
{
  imports = [
    ./audio.nix
    ./networking.nix
    ./i18n.nix
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
