{ pkgs, ... }:

# System side of the niri session; its configuration lives in modules/home/niri.nix.
{
  imports = [ ./graphical.nix ];

  programs.niri = {
    enable = true;
    # Opens files through the GTK portal instead of pulling in Nautilus for the GNOME one.
    useNautilus = false;
  };

  # Installs the PAM service hyprlock authenticates against.
  programs.hyprlock.enable = true;

  # niri starts xwayland-satellite on demand when it finds it on PATH.
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  # The NVIDIA driver keeps freed buffers in a per-process pool, which grows niri's VRAM use toward 1 GiB.
  # https://github.com/NVIDIA/egl-wayland/issues/126#issuecomment-2379945259
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri.json".text =
    let
      profile = "Limit free buffer pool in niri";
    in
    builtins.toJSON {
      rules = [
        {
          pattern = {
            feature = "procname";
            matches = "niri";
          };
          inherit profile;
        }
      ];
      profiles = [
        {
          name = profile;
          settings = [
            {
              key = "GLVidHeapReuseRatio";
              value = 0;
            }
          ];
        }
      ];
    };
}
