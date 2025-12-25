# NixOS Workstation Profile
# Desktop development machine with KDE Plasma, NVIDIA GPU, and full audio setup
{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/nix.nix
    ../modules/fonts.nix
    ../modules/base.nix
    ../modules/desktop.nix
    ../modules/nvidia.nix
    ../modules/audio.nix
    ../modules/networking.nix
    ../modules/i18n.nix
    ../modules/power.nix
  ];
}
