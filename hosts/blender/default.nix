{
  inputs,
  lib,
  modules,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    modules.nixos.default
    modules.nixos.plasma
    modules.nixos.hyprland
    modules.nixos.nvidia
    modules.system.fonts
    ./hardware.nix
    ./disko.nix
    ./boot.nix
    ./containers.nix
    ./btrfs.nix
    ./users.nix
  ];

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Seoul";

  services.openssh.enable = false;
  networking.firewall.allowedTCPPorts = lib.mkForce [ ];

  zramSwap.enable = true;

  system.stateVersion = "26.11";
}
