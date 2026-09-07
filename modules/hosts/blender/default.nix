{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.inventory.hosts.blender = {
    system = "x86_64-linux";
    backend = "nixos";
    primaryAccount = "citrus@blender";
    aspect = {
      includes = [
        features.core
        features.nixos
      ];
      nixos = ./nixos.nix;
    };
  };
}
