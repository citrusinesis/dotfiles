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
    ./users.nix
  ];

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Seoul";

  # Local-only machine: no SSH keys are authorized, so the shared OpenSSH
  # default would only expose a port nobody can log in through.
  services.openssh.enable = false;
  networking.firewall.allowedTCPPorts = lib.mkForce [ ];

  # zram takes priority; the btrfs swapfile in disko.nix is the overflow before OOM.
  zramSwap.enable = true;

  system.stateVersion = "26.11";
}
