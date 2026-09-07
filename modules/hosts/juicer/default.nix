{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.inventory.hosts.juicer = {
    system = "aarch64-darwin";
    backend = "darwin";
    primaryAccount = "citrus@juicer";
    aspect = {
      includes = [
        features.core
        features.darwin
        features.apple-container
      ];
      darwin = ./darwin.nix;
    };
  };
}
