{ lib, pkgs, ... }:

{
  dotfiles.casks = [ "discord" ];

  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.discord ];
}
