{ lib, pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      curl
      wget
      jq
      less
      watch
      unzip

      tree
      fastfetch
      entr
      file
      dust
      duf
      procs
      rsync
      ast-grep
      lazygit
      tldr

      gnupg
      keychain
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      coreutils
    ];
}
