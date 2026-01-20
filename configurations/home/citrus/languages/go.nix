{ pkgs, ... }:

{
  home.packages = with pkgs; [
    go
    gopls
    delve
    golangci-lint
    gotools
    go-tools
    gomodifytags
    impl
    gotests
  ];
}
