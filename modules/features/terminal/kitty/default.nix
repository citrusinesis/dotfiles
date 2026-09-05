{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.aspects.features.provides.kitty = {
    darwin = ./darwin.nix;
    homeManager = ./home.nix;
    includes = [ features.theme ];
  };
}
