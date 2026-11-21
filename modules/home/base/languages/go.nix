{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    go
    (lib.hiPrio gopls)
    delve
    golangci-lint
    gotools
    go-tools
    gomodifytags
    impl
    gotests
  ];
}
