{
  lib,
  pkgs,
  username,
  ...
}:

{
  options.dotfiles.home.gui.enable = lib.mkEnableOption "graphical Home Manager integrations";

  config = {
    home.username = username;
    home.homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
    );
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
    targets.darwin.linkApps.enable = lib.mkIf pkgs.stdenv.isDarwin true;
    targets.darwin.copyApps.enable = lib.mkIf pkgs.stdenv.isDarwin false;
  };
}
