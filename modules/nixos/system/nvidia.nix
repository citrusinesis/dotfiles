{
  config,
  pkgs,
  lib,
  ...
}:

{
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {
      offload.enable = true;
      intelBusId = lib.mkDefault "PCI:0:2:0";
      nvidiaBusId = lib.mkDefault "PCI:2:0:0";
    };
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
