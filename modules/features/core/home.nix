{
  dotfilesUnmanaged,
  lib,
  pkgs,
  ...
}:
{
  programs.home-manager.enable = true;

  home.packages = [ (lib.lowPrio pkgs.vim) ];
  home.sessionVariables = {
    EDITOR = lib.mkDefault "vim";
    VISUAL = lib.mkDefault "vim";
  };

  home.sessionPath = lib.optionals pkgs.stdenv.hostPlatform.isDarwin (
    [
      "/nix/var/nix/profiles/system/sw/bin"
      "/usr/local/bin"
    ]
    ++ lib.optional dotfilesUnmanaged "/opt/homebrew/bin"
  );

  targets.darwin.linkApps.enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin false;
  targets.darwin.copyApps.enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin false;
}
