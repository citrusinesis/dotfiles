{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
  profiles = config.dotfiles.aspects.profiles.provides;
in
{
  dotfiles.aspects.hosts.provides.ws-jh-song = {
    includes = [
      features.core
      features.nixos
      profiles.developer
      features.nvidia-lxc
    ];
    nixos = ./nixos.nix;
  };
}
