{
  lib,
  pkgs,
  writeShellApplication,
  coreutils,
  findutils,
  gnugrep,
  nix,
  apple-container ? null,
}:

import ./create.nix {
  inherit
    lib
    pkgs
    writeShellApplication
    coreutils
    findutils
    gnugrep
    nix
    apple-container
    ;
}
