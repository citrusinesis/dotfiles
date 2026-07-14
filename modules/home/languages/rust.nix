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
    if pkgs.stdenv.isDarwin then
      pkgs.cargo-watch.override {
        rustPlatform = pkgs.rustPlatform // {
          buildRustPackage =
            args:
            let
              useLld =
                attrs:
                attrs
                // {
                  nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [ pkgs.llvmPackages.lld ];
                  RUSTFLAGS = "-C link-arg=-fuse-ld=lld";
                };
            in
            pkgs.rustPlatform.buildRustPackage (
              if builtins.isFunction args then finalAttrs: useLld (args finalAttrs) else useLld args
            );
        };
      }
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
