{ pkgs, ... }:

let
  toolchain = pkgs.fenix.complete.withComponents [
    "cargo"
    "clippy"
    "rust-analyzer"
    "rust-src"
    "rustc"
    "rustfmt"
  ];
in
{
  home.packages = [
    toolchain
  ]
  ++ (with pkgs; [
    cargo-edit
    cargo-watch
    cargo-expand
    cargo-audit
    cargo-deny
    cargo-outdated
  ]);

  home.file.".rustfmt.toml".source = ./rustfmt.toml;
}
