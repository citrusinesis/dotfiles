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

import ../apple-container-machine/create.nix {
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
