{
  config,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:

let
  # On darwin, only install podman when the host selected it as its
  # container runtime (see modules/darwin/container-runtime.nix).
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
          type = "insecureAcceptAnything";
        }
      ];
      transports = {
        docker-daemon = {
          "" = [
            {
              type = "insecureAcceptAnything";
            }
          ];
        };
      };
    };

    xdg.configFile."containers/registries.conf".text = ''
      [registries.search]
      registries = ["docker.io", "registry.fedoraproject.org", "quay.io", "registry.redhat.io", "registry.centos.org"]

      [registries.insecure]
      registries = []

      [registries.block]
      registries = []
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
