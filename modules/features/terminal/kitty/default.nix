{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.aspects.features.provides.kitty = {
    homeManager = ./home.nix;
    includes = [ features.theme ];
  };
}
