{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.nvidiaLxc;
in
{
  options.dotfiles.nvidiaLxc = {
    enable = lib.mkEnableOption "NVIDIA devices passed through to an LXC container";

    driverPackage = lib.mkOption {
      type = lib.types.package;
      description = ''
        NVIDIA user-space driver package matching the driver loaded by the LXC
        host. The versions must match exactly.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # /dev/nvidia* is owned by the host. Only expose matching user-space
    # libraries; loading a kernel module from the container is neither needed
    # nor possible.
    hardware.graphics = {
      enable = true;
      extraPackages = [ cfg.driverPackage.out ];
    };

    environment.systemPackages = [
      cfg.driverPackage.bin
      pkgs.nvtopPackages.nvidia
    ];

    users.users.${config.dotfiles.primaryUser}.extraGroups = [
      "video"
      "render"
    ];
  };
}
