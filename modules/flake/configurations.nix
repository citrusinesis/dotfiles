{ config, inputs, ... }:
let
  hosts = config.dotfiles.aspects.hosts.provides;
  personal = import ../../personal.nix;
  mkDarwin = import ../../lib/mk-darwin.nix { inherit inputs; };
  mkNixos = import ../../lib/mk-nixos.nix { inherit inputs; };
in
{
  flake = {
    darwinConfigurations = {
      juicer = mkDarwin {
        aspect = hosts.juicer;
        username = personal.user.username;
      };
      mixer = mkDarwin {
        aspect = hosts.mixer;
        username = personal.user.username;
      };
    };
    nixosConfigurations = {
      blender = mkNixos {
        aspect = hosts.blender;
        username = personal.user.username;
      };
      ws-jh-song = mkNixos {
        aspect = hosts.ws-jh-song;
        username = "jh-song";
      };
    };
  };
}
