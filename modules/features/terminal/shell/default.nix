{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.aspects.features.provides.shell = {
    homeManager = ./home.nix;
    includes = [ features.theme ];
  };
}
