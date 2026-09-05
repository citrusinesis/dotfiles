{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.aspects.features.provides.ghostty = {
    homeManager = ./home.nix;
    includes = [ features.theme ];
  };
}
