{
  config,
  pkgs,
  ...
}:

{
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
}
