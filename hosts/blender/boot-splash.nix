{
  boot = {
    plymouth = {
      enable = true;
      theme = "bgrt";
    };
    consoleLogLevel = 3;
    initrd = {
      # NVIDIA modesetting supplies modeset=1 and fbdev=1 through modprobe.
      kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_drm"
      ];
    };
    # Plymouth adds splash; quiet also silences the systemd initrd.
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "rd.udev.log_level=3"
    ];
  };
}
