{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.home.podman;
in
{
  options.dotfiles.home.podman.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Whether to install and configure the Podman client for this Home Manager profile.
      This is opt-in and must be enabled explicitly for each Home Manager profile.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.podman ];

    xdg.configFile."containers/policy.json".text = builtins.toJSON {
      default = [
        {
          type = "reject";
        }
      ];
      transports = {
        docker = {
          "" = [ { type = "insecureAcceptAnything"; } ];
        };
        docker-daemon = {
          "" = [ { type = "insecureAcceptAnything"; } ];
        };
        containers-storage = {
          "" = [ { type = "insecureAcceptAnything"; } ];
        };
        docker-archive = {
          "" = [ { type = "insecureAcceptAnything"; } ];
        };
        oci-archive = {
          "" = [ { type = "insecureAcceptAnything"; } ];
        };
      };
    };

    xdg.configFile."containers/registries.conf".text = ''
      unqualified-search-registries = ["docker.io"]
      short-name-mode = "enforcing"
    '';

    xdg.configFile."containers/storage.conf".text = ''
      [storage]
      driver = "overlay"
      graphroot = "${config.xdg.dataHome}/containers/storage"

      [storage.options]
      additionalimagestores = []

      [storage.options.overlay]
      mountopt = "nodev,metacopy=on"
    '';
  };
}
