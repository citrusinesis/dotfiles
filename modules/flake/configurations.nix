{
  config,
  inputs,
  lib,
  ...
}:
{
  flake = import ../../lib/mk-configurations.nix { inherit inputs lib; } config.dotfiles.inventory;
}
