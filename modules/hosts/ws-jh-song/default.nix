{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.inventory.hosts.ws-jh-song = {
    system = "x86_64-linux";
    backend = "nixos";
    primaryAccount = "jh-song@ws-jh-song";
    aspect = {
      includes = [
        features.core
        features.nixos
        features.nvidia-lxc
      ];
      nixos = ./nixos.nix;
    };
  };
}
