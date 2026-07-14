{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.containerRuntime;
in
{
  options.containerRuntime = lib.mkOption {
    type = lib.types.nullOr (
      lib.types.enum [
        "container"
        "docker"
        "orbstack"
        "podman"
      ]
    );
    default = null;
    description = "Container runtime used on this host (exactly one).";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg == "container") {
      environment.systemPackages = [ pkgs.dotfilesPackages.apple-container ];
      # The CLI resolves plugins relative to its install root.
      environment.pathsToLink = [ "/libexec" ];
    })

    (lib.mkIf (cfg == "orbstack") {
      homebrew.casks = [ "orbstack" ];
    })

    (lib.mkIf (cfg == "docker") {
      homebrew.casks = [ "docker-desktop" ];
    })

    # Podman is configured by its Home Manager module.
  ];
}
