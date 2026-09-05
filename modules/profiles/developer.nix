{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.aspects.profiles.provides.developer.includes = [
    features.cli
    features.shell
    features.languages
    features.tools
    features.nixvim
  ];
}
