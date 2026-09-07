# Example flake-parts module; deliberately not imported by the real inventory.
# Replace the login/host IDs with the existing USER and detected hostname.
{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.inventory = {
    users.example.aspect = {
      includes = [
        features.cli
        features.shell
        features.languages
        features.tools
      ];
    };
    hosts = {
      linux-laptop = {
        system = "x86_64-linux";
        backend = "unmanaged";
        aspect.includes = [ features.core ];
      };
      personal-mac = {
        system = "aarch64-darwin";
        backend = "unmanaged";
        aspect.includes = [
          features.core
          features.darwin
        ];
      };
    };
    accounts = {
      "example@linux-laptop" = {
        home.stateVersion = "25.11";
        aspect.includes = [ features.fonts ];
      };
      "example@personal-mac" = {
        home.stateVersion = "25.11";
        aspect.includes = [
          features.fonts
          features.ghostty
          features.zed
        ];
      };
    };
  };
}
