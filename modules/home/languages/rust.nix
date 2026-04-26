{ pkgs, ... }:

let
  toolchain = pkgs.fenix.complete.withComponents [
    "cargo"
    "clippy"
    "rust-src"
    "rustc"
    "rustfmt"
  ];
in
{
  home.packages = [
    toolchain
    pkgs.fenix.rust-analyzer
  ]
  ++ (with pkgs; [
    cargo-edit
    cargo-watch
    cargo-expand
    cargo-audit
    cargo-deny
    cargo-outdated
  ]);

  xdg.configFile."rustfmt/rustfmt.toml".source = ./rustfmt.toml;
}
