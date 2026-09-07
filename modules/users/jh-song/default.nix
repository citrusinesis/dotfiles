{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.inventory.users.jh-song.aspect = {
    includes = [
      features.cli
      features.shell
      features.languages
      features.tools
      features.nixvim
    ];
    homeManager = ../git-identity.nix;
  };
}
