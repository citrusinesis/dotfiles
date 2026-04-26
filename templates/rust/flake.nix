{
  description = "Rust service template with fenix and company defaults";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      fenix,
    }:
    let
      pname = "rust-service";
      version = "0.1.0";
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fenix.overlays.default ];
        };
        inherit (pkgs) lib;
        rustToolchain = pkgs.fenix.complete.withComponents [
          "cargo"
          "clippy"
          "rust-src"
          "rustc"
          "rustfmt"
        ];
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };
      in
      {
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/${pname}";
        };

        devShells.default = pkgs.mkShell {
          packages =
            (with pkgs; [
              rustToolchain
              pkgs.fenix.rust-analyzer

              cargo-audit
              cargo-deny
              cargo-edit
              cargo-expand
              cargo-outdated
              cargo-watch
              sccache
            ])
            ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.mold ];

          env = {
            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
            RUSTC_WRAPPER = "sccache";
          }
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            RUSTFLAGS = "-C link-arg=-fuse-ld=mold";
          };
        };

        packages.default = rustPlatform.buildRustPackage {
          inherit pname version;
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
        };
      }
    );
}
