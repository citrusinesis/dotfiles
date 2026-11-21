{ lib, pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      bear
      cmake
      neocmakelsp
      ninja
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      clang-tools
      lldb
    ];
}
