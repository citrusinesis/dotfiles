{
  config,
  pkgs,
  ...
}:

# A single discrete GPU driving the display. Hybrid topology (PRIME bus IDs,
# RTD3 power-off) is a property of the physical machine and belongs in its host.
{
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.nvidia-vaapi-driver ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = true;
    # Blackwell (RTX 50) and newer are supported only by the open kernel modules.
    open = true;
    nvidiaSettings = true;
    # Preserves VRAM contents across suspend so Wayland sessions survive resume.
    powerManagement.enable = true;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
