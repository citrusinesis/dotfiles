{ lib, pkgs, ... }:
{
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.packages = [ (lib.lowPrio pkgs.vim) ];
  home.sessionVariables = {
    EDITOR = lib.mkDefault "vim";
    VISUAL = lib.mkDefault "vim";
  };

  home.sessionPath = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "/etc/profiles/per-user/$USER/bin"
    "/nix/var/nix/profiles/system/sw/bin"
    "/usr/local/bin"
  ];

  targets.darwin.linkApps.enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin false;
  targets.darwin.copyApps.enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin false;
}
