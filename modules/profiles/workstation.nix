{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.aspects.profiles.provides.workstation.includes = [
    features.fonts
    features.applications
    features.ghostty
    features.zed
    features.winbox
  ];
}
