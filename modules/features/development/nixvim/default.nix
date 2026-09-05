{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.aspects.features.provides.nixvim = {
    homeManager = ./home.nix;
    includes = [ features.theme ];
  };
}
