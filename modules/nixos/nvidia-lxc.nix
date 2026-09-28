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
    driverPackage = lib.mkOption {
      type = lib.types.package;
      description = ''
        NVIDIA user-space driver package matching the driver loaded by the LXC
        host. The versions must match exactly.
      '';
    };
  };

  config = {
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

  };
}
