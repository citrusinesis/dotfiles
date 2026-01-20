{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt
    cargo-edit
    cargo-watch
    cargo-expand
    cargo-audit
  ];
}
