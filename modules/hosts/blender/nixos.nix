{
  config,
  inputs,
  lib,
  ...
}:

let
  username = config.dotfiles.primaryUser;
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  networking.networkmanager.enable = false;

  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
    useWindowsDriver = true;

    interop.includePath = false;

    docker-desktop.enable = true;

    wslConf = {
      boot.systemd = true;

      interop = {
        enabled = true;
        appendWindowsPath = false;
      };

      automount = {
        enabled = true;
        root = "/mnt";
        mountFsTab = false;
        options = "metadata,uid=1000,gid=100,umask=022,fmask=011";
      };

      network.hostname = "blender";
      time.useWindowsTimezone = true;
    };
  };

  programs.nix-ld.libraries = config.hardware.graphics.extraPackages;

  powerManagement.enable = false;
  services.timesyncd.enable = lib.mkForce false;
  system.stateVersion = "25.11";
}
