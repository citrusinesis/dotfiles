{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.inventory.accounts."citrus@mixer" = {
    home = {
      stateVersion = "25.11";
    };
    aspect = {
      includes = [
        features.fonts
        features.applications
        features.ghostty
        features.zed
        features.winbox
      ];
      darwin = ./darwin.nix;
    };
  };
}
