{
  dotfilesUnmanaged,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf dotfilesUnmanaged {
    home.packages = import ./packages.nix { inherit pkgs lib; };
    fonts.fontconfig.enable = pkgs.stdenv.hostPlatform.isLinux;
  };
}
