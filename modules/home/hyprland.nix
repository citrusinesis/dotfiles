{ lib, pkgs, ... }:

let
  inherit (lib.generators) mkLuaInline;

  terminal = "ghostty";
  mod = "SUPER";

  dispatch = expression: mkLuaInline "hl.dsp.${expression}";
  exec = command: dispatch "exec_cmd(${builtins.toJSON command})";
  # UWSM launches every app in its own systemd scope so it inherits the session environment.
  launch = command: exec "uwsm app -- ${command}";
  bind = keys: action: {
    _args = [
      keys
      action
    ];
  };
  bindWith = keys: action: flags: {
    _args = [
      keys
      action
      flags
    ];
  };

  directions = {
    H = "left";
    J = "down";
    K = "up";
    L = "right";
  };
  directionBinds = lib.concatLists (
    lib.mapAttrsToList (key: direction: [
      (bind "${mod} + ${key}" (dispatch "focus({ direction = \"${direction}\" })"))
      (bind "${mod} + SHIFT + ${key}" (dispatch "window.move({ direction = \"${direction}\" })"))
    ]) directions
  );

  workspaceBinds = lib.concatMap (
    n:
    let
      key = toString (lib.mod n 10);
    in
    [
      (bind "${mod} + ${key}" (dispatch "focus({ workspace = ${toString n} })"))
      (bind "${mod} + SHIFT + ${key}" (dispatch "window.move({ workspace = ${toString n} })"))
    ]
  ) (lib.range 1 10);

  mediaKey = {
    locked = true;
    repeating = true;
  };

  # hyprctl dispatch evaluates a Lua dispatcher expression, the same as a bind.
  hyprctlDispatch = expression: "hyprctl dispatch ${lib.escapeShellArg "hl.dsp.${expression}"}";
in
{
  imports = [ ./theme.nix ];

  wayland.windowManager.hyprland = {
    enable = true;
    # The NixOS module installs Hyprland and its portal, and UWSM owns the
    # systemd session, so Home Manager only writes the configuration.
    package = null;
    portalPackage = null;
    systemd.enable = false;

    settings = {
      monitor = {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = "auto";
      };

      config = {
        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          layout = "dwindle";
        };

        decoration.rounding = 8;

        dwindle.preserve_split = true;

        input = {
          kb_layout = "us";
          follow_mouse = 1;
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };
      };

      bind = [
        (bind "${mod} + Return" (launch terminal))
        (bind "${mod} + space" (exec "fuzzel"))
        (bind "${mod} + Q" (dispatch "window.close()"))
        (bind "${mod} + F" (dispatch "window.fullscreen()"))
        (bind "${mod} + V" (dispatch "window.float({ action = \"toggle\" })"))
        (bind "${mod} + Escape" (exec "loginctl lock-session"))
        (bind "${mod} + SHIFT + Escape" (exec "uwsm stop"))

        (bind "Print" (exec "grim -g \"$(slurp)\" - | wl-copy"))
        (bind "SHIFT + Print" (exec "grim - | wl-copy"))

        (bindWith "${mod} + mouse:272" (dispatch "window.drag()") { mouse = true; })
        (bindWith "${mod} + mouse:273" (dispatch "window.resize()") { mouse = true; })

        (bindWith "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+") mediaKey)
        (bindWith "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") mediaKey)
        (bindWith "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") mediaKey)
      ]
      ++ directionBinds
      ++ workspaceBinds;
    };
  };

  # Under UWSM, `env` in hyprland.conf reaches only the compositor; apps read
  # the session environment from this file instead.
  xdg.configFile."uwsm/env".text = ''
    export QT_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx
    export SDL_IM_MODULE=fcitx
  '';

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "top";
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "network"
        "tray"
      ];

      clock.format = "{:%m/%d %a %H:%M}";
      pulseaudio = {
        format = "vol {volume}%";
        format-muted = "muted";
        on-click = "pwvucontrol";
      };
      network = {
        format-ethernet = "{ipaddr}";
        format-wifi = "{essid} {signalStrength}%";
        format-disconnected = "offline";
      };
    };
  };

  programs.fuzzel = {
    enable = true;
    settings.main = {
      inherit terminal;
      launch-prefix = "uwsm app --";
      font = "Hack Nerd Font:size=12";
    };
  };

  services.mako.enable = true;

  programs.hyprlock.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = hyprctlDispatch "dpms({ action = \"on\" })";
      };

      listener = [
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = hyprctlDispatch "dpms({ action = \"off\" })";
          on-resume = hyprctlDispatch "dpms({ action = \"on\" })";
        }
      ];
    };
  };

  services.hyprpolkitagent.enable = true;

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    pwvucontrol
  ];
}
