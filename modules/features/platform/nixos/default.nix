{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.aspects.features.provides = {
    nixos.nixos = ./nixos.nix;
    nixos-graphical = {
      includes = [
        features.nixos
        features.fonts
      ];
      nixos = ./graphical.nix;
    };
    nvidia.nixos = ./nvidia.nix;
    nvidia-lxc.nixos = ./nvidia-lxc.nix;
    always-on.nixos = ./power.nix;
    tailscale-exit-node.nixos = ./tailscale-exit-node.nix;
  };
}
