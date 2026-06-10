{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.containerRuntime;

  # `container system start` does not re-register an apiserver that is
  # already bootstrapped in launchd, so stop first to heal stale
  # registrations (e.g. pointing at a previous package's store path).
  containerSystemStart = pkgs.writeShellScript "container-system-start" ''
    ${pkgs.apple-container}/bin/container system stop || true
    exec ${pkgs.apple-container}/bin/container system start --enable-kernel-install
  '';
in
{
  options.containerRuntime = lib.mkOption {
    type = lib.types.nullOr (
      lib.types.enum [
        "container"
        "orbstack"
        "podman"
      ]
    );
    default = null;
    description = "Container runtime used on this host (exactly one).";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg == "container") {
      environment.systemPackages = [ pkgs.apple-container ];
      # The apiserver resolves plugins from its install root; expose
      # libexec/ in the system profile for invocations via $PATH.
      environment.pathsToLink = [ "/libexec" ];

      launchd.user.agents.container-system-start = {
        serviceConfig = {
          ProgramArguments = [ "${containerSystemStart}" ];
          RunAtLoad = true;
        };
      };
    })

    (lib.mkIf (cfg == "orbstack") {
      homebrew.casks = [ "orbstack" ];
    })

    # "podman" has no system-level pieces; modules/home/dev/podman.nix
    # enables itself on darwin when this option is set to "podman".
  ];
}
