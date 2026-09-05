{ lib, ... }:
{
  imports = [ ./module.nix ];
  dotfiles.home.appleContainer.enable = lib.mkDefault true;
}
