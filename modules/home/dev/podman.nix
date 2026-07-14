{
  config,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:

let
  enabled = !pkgs.stdenv.isDarwin || (osConfig.containerRuntime or null) == "podman";
in
{
  config = lib.mkIf enabled {
    home.packages =
      with pkgs;
      [
        podman
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        containerd
      ];

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
