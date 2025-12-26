{ lib, config, pkgs, ... }:

{
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      add_newline = true;
      scan_timeout = 30;
      command_timeout = 1000;

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold green)";
      };
    };
  };

  home.activation.starshipConfigDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${config.xdg.configHome}
  '';
}
