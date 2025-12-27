{ pkgs, lib, username, ... }:

let
  personal = import ../../personal.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/workstation.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = lib.mkForce false;

  networking.hostName = "blender";
  time.timeZone = personal.timezone;

  home-manager.backupFileExtension = "backup";

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "25.11";
}
