{
  inputs,
  lib,
  modules,
  pkgs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    modules.nixos.default
    modules.nixos.plasma
    modules.nixos.niri
    modules.nixos.nvidia
    modules.system.fonts
    ./hardware.nix
    ./disko.nix
    ./boot.nix
    ./containers.nix
    ./data-disk.nix
    ./btrfs.nix
    ./keyboard.nix
    ./users.nix
  ];

  # Track the latest stable kernel available in the locked nixpkgs input.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.displayManager.defaultSession = "niri";

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Seoul";

  services.openssh.enable = false;
  networking.firewall.allowedTCPPorts = lib.mkForce [ ];

  zramSwap.enable = true;

  system.stateVersion = "26.11";
}
