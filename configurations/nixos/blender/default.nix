{
  config,
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
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  dotfiles.primaryUser = username;

  networking.hostName = "blender";
  networking.networkmanager.enable = lib.mkForce false;

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

  powerManagement.enable = lib.mkForce false;
  services.timesyncd.enable = lib.mkForce false;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  home-manager = {
    backupFileExtension = "bak";
    users.${username} = {
      imports = [
        self.homeModules.base
        self.homeModules.headless-development
      ];
      dotfiles.home.username = username;
    };
  };

  system.stateVersion = "25.11";
}
