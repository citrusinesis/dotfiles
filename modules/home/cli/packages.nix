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
      rsync
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      coreutils
    ];
}
