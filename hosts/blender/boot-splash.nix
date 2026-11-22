{
  services.bootvine.enable = true;

  console.colors = [
    "1e1e2e"
    "f38ba8"
    "a6e3a1"
    "f9e2af"
    "89b4fa"
    "f5c2e7"
    "94e2d5"
    "bac2de"
    "585b70"
    "f38ba8"
    "a6e3a1"
    "f9e2af"
    "89b4fa"
    "f5c2e7"
    "94e2d5"
    "a6adc8"
  ];

  boot = {
    consoleLogLevel = 3;
    initrd = {
      # NVIDIA modesetting supplies modeset=1 and fbdev=1 through modprobe.
      kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_drm"
      ];
    };
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "rd.udev.log_level=3"
    ];
  };
}
