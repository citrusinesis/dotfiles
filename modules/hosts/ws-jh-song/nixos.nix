{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./capitol-workspace.nix
    ./nvidia.nix
  ];

  proxmoxLXC = {
    manageHostName = true;
    # Keep the Proxmox-side network definition outside this Git flake.
    manageNetwork = false;
  };

  networking.networkmanager.enable = false;
  time.timeZone = "Asia/Seoul";

  services.tailscale.enable = true;

  # Keep OpenSSH as a break-glass path if Tailscale SSH is unavailable.
  services.openssh.enable = lib.mkForce true;
  services.openssh.startWhenNeeded = lib.mkForce false;

  powerManagement.enable = false;

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.specialFileSystems."/sys/kernel/debug".enable = lib.mkForce false;
  boot.specialFileSystems."/sys/kernel/tracing".enable = lib.mkForce false;

  users.groups.shared.gid = 20001;

  virtualisation.docker = {
    enable = true;
    # The ZFS-backed root would make the daemon auto-select the zfs storage
    # driver, which cannot manage datasets inside an unprivileged LXC.
    storageDriver = "overlay2";
  };

  system.stateVersion = "25.11";
}
