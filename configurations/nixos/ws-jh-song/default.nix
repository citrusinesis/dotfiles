{
  flake,
  lib,
  modulesPath,
  pkgs,
  ...
}:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  personal = import (self + /personal.nix);
  username = personal.user.username;
in
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")

    self.nixosModules.minimal
    inputs.home-manager.nixosModules.home-manager
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.overlays = [ self.overlays.default ];

  proxmoxLXC = {
    manageHostName = true;
    # Keep workspace-specific IP/gateway/DNS outside this Git flake. Capitol
    # should provide them via Proxmox or /etc/systemd/network/*.network.
    manageNetwork = false;
  };

  networking.hostName = "ws-jh-song";
  networking.networkmanager.enable = lib.mkForce false;
  time.timeZone = personal.timezone;

  services.tailscale.enable = true;
  services.openssh.enable = lib.mkForce false;
  services.openssh.startWhenNeeded = lib.mkForce false;

  security.sudo.wheelNeedsPassword = lib.mkForce false;

  powerManagement.enable = lib.mkForce false;

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.specialFileSystems."/sys/kernel/debug".enable = lib.mkForce false;
  boot.specialFileSystems."/sys/kernel/tracing".enable = lib.mkForce false;

  users.groups.${username} = { };
  users.users.${username} = {
    isNormalUser = true;
    group = username;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${username} = import (self + /configurations/home/default);
    extraSpecialArgs = { inherit flake; };
  };

  system.stateVersion = "25.11";
}
