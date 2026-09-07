{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.inventory.accounts."citrus@juicer" = {
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
        features.paneru
      ];
      darwin = ./darwin.nix;
    };
  };
}
