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
      pkgs.unstable.claude-code
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      coreutils
    ];
}
