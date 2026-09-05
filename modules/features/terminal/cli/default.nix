{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.aspects.features.provides.cli = {
    homeManager = ./home.nix;
    includes = [ features.theme ];
  };
}
