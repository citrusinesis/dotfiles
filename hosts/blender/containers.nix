{ ... }:

{
  virtualisation.docker = {
    enable = true;
    # GPUs are exposed through CDI: `docker run --device nvidia.com/gpu=all ...`.
    daemon.settings.features.cdi = true;
  };

  hardware.nvidia-container-toolkit.enable = true;
}
