{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
  profiles = config.dotfiles.aspects.profiles.provides;
in
{
  dotfiles.aspects.hosts.provides.mixer = {
    includes = [
      features.core
      features.darwin
      profiles.developer
      profiles.workstation
      features.apple-container
    ];
    darwin = ./darwin.nix;
  };
}
