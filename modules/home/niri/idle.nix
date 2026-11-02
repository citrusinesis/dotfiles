{ ... }:

let
  niriAction = name: "niri msg action ${name}";
in
{
  programs.hyprlock.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = niriAction "power-on-monitors";
      };

      listener = [
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = niriAction "power-off-monitors";
          on-resume = niriAction "power-on-monitors";
        }
      ];
    };
  };
}
