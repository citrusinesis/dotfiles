{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.inventory.users.citrus.aspect = {
    includes = [
      features.cli
      features.shell
      features.languages
      features.tools
      features.nixvim
      features.darwin-preferences
    ];
    homeManager = ../git-identity.nix;
  };
}
