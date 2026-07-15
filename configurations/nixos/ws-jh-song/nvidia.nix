{
  config,
  flake,
  ...
}:

let
  # An LXC container uses the host's loaded kernel module.  CUDA requires the
  # user-space driver to match that module exactly, so do not replace this with
  # nvidiaPackages.latest without upgrading the Proxmox host at the same time.
  hostNvidiaDriver =
    (config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "595.58.03";
      sha256_64bit = "sha256-jA1Plnt5MsSrVxQnKu6BAzkrCnAskq+lVRdtNiBYKfk=";
      useSettings = false;
      usePersistenced = false;
    }).override
      {
        acceptLicense = true;
      };

in
{
  imports = [ (flake.inputs.self + /modules/nixos/system/nvidia-lxc.nix) ];

  dotfiles.nvidiaLxc = {
    enable = true;
    driverPackage = hostNvidiaDriver;
  };
}
