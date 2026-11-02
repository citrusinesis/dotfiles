{ lib, pkgs, ... }:

let
  # swayidle runs its commands with only a shell on PATH.
  loginctl = "${pkgs.systemd}/bin/loginctl";
  niriAction = name: "${lib.getExe pkgs.niri} msg action ${name}";
  lock = "${lib.getExe pkgs.swaylock} -f";
in
{
  programs.swaylock = {
    enable = true;
    # catppuccin's swaylock theme is read at evaluation time from a built source, which a non-Linux machine cannot evaluate.
    settings.color = "1e1e2e";
  };
  catppuccin.swaylock.enable = false;

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 600;
        command = "${loginctl} lock-session";
      }
      {
        timeout = 900;
        command = niriAction "power-off-monitors";
        resumeCommand = niriAction "power-on-monitors";
      }
    ];
    events = {
      inherit lock;
      before-sleep = lock;
    };
  };
}
