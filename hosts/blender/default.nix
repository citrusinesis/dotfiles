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
    modules.nixos.niri
    modules.nixos.noctalia
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

  environment.systemPackages = [ pkgs.efibootmgr ];

  services.displayManager.defaultSession = "niri";
  services.displayManager.noctalia-greeter.settings.output = {
    name = "Dell Inc. DELL U2725QE 8DNMGF4";
    width = 3840;
    height = 2160;
    refresh_rate = 120;
    scale = 1.25;
  };

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Seoul";

  services.openssh.enable = false;
  networking.firewall.allowedTCPPorts = lib.mkForce [ ];

  zramSwap.enable = true;

  system.stateVersion = "26.11";
}
