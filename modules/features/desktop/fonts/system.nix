{ pkgs, lib, ... }:
{
  fonts.packages = import ./packages.nix { inherit pkgs lib; };
}
