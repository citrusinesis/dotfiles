{
  flake,
  lib,
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
    inputs.nixos-wsl.nixosModules.default

    self.nixosModules.minimal
    inputs.home-manager.nixosModules.home-manager
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.overlays = [ self.overlays.default ];

  networking.hostName = "blender";
  networking.networkmanager.enable = lib.mkForce false;

  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
    useWindowsDriver = true;

    interop.includePath = false;

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

  powerManagement.enable = lib.mkForce false;
  services.timesyncd.enable = lib.mkForce false;
  security.sudo.wheelNeedsPassword = lib.mkForce false;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    users.${username} = import (self + /configurations/home/headless);
    extraSpecialArgs = { inherit flake username; };
  };

  system.stateVersion = "25.11";
}
