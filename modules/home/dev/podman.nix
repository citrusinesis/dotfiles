{
  config,
  lib,
  pkgs,
  ...
}:

{
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
    runroot = "/run/user/1000/containers"
    graphroot = "${config.xdg.dataHome}/containers/storage"

    [storage.options]
    additionalimagestores = []

    [storage.options.overlay]
    mountopt = "nodev,metacopy=on"
  '';
}
