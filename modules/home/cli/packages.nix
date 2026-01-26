{ lib, pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      tree
      fastfetch
      entr
      file
      dust
      duf
      procs
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      coreutils
    ];
}
