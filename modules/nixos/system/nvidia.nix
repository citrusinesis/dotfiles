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

    prime.offload.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
