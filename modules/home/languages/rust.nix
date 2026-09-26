{ pkgs, ... }:

let
  toolchain = pkgs.fenix.complete.withComponents [
    "cargo"
    "clippy"
    "rust-src"
    "rustc"
    "rustfmt"
  ];

  # Darwin's cctools linker crashes while linking cargo-watch. Use LLVM's
  # Mach-O linker for this package and leave other Rust packages unchanged.
  cargoWatch =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.cargo-watch.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.llvmPackages.lld ];
        RUSTFLAGS = "-C link-arg=-fuse-ld=lld";
      })
    else
      pkgs.cargo-watch;
in
{
  home.packages = [
    toolchain
    pkgs.fenix.rust-analyzer
  ]
  ++ (with pkgs; [
    cargo-edit
    cargoWatch
    cargo-expand
    cargo-audit
    cargo-deny
    cargo-outdated
  ]);

  home.file.".rustfmt.toml".source = ./rustfmt.toml;
}
