{ flake, ... }:

{
  imports = [ flake.inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";

    starship.enable = false;
    zed.enable = false;

    tmux = {
      enable = true;
      extraConfig = ''
        set -g @catppuccin_window_status_style "rounded"
      '';
    };
  };
}
