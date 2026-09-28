{ lib, pkgs, ... }:

{
  dotfiles.casks = [ "winbox" ];

  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.winbox ];
}
