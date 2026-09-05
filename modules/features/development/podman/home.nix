{ lib, ... }:
{
  imports = [ ./module.nix ];
  dotfiles.home.podman.enable = lib.mkDefault true;
}
