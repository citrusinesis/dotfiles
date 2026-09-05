{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
  profiles = config.dotfiles.aspects.profiles.provides;
in
{
  dotfiles.aspects.hosts.provides.blender = {
    includes = [
      features.core
      features.nixos
      profiles.developer

    ];
    nixos = ./nixos.nix;
  };
}
