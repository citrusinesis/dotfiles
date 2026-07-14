{
  description = "Rust service template with a complete Fenix toolchain";

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
    flake-utils.lib.eachSystem
      [
        "aarch64-darwin"
        "x86_64-linux"
      ]
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ fenix.overlays.default ];
          };
          inherit (pkgs) lib;
          buildToolchain = pkgs.fenix.complete.withComponents [
            "cargo"
            "rustc"
          ];
          developmentToolchain = pkgs.fenix.complete.withComponents [
            "cargo"
            "clippy"
            "rust-src"
            "rustc"
            "rustfmt"
          ];
          rustPlatform = pkgs.makeRustPlatform {
            cargo = buildToolchain;
            rustc = buildToolchain;
          };
          package = rustPlatform.buildRustPackage {
            inherit pname version;
            src = ./.;
            cargoLock.lockFile = ./Cargo.lock;
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
                developmentToolchain
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
              RUST_SRC_PATH = "${developmentToolchain}/lib/rustlib/src/rust/library";
              RUSTC_WRAPPER = "sccache";
            }
            // lib.optionalAttrs pkgs.stdenv.isLinux {
              RUSTFLAGS = "-C link-arg=-fuse-ld=mold";
            };
          };

          packages.default = package;

          checks = {
            default = package;
            formatting =
              pkgs.runCommand "${pname}-formatting"
                {
                  nativeBuildInputs = [ developmentToolchain ];
                }
                ''
                  cp -R ${./.} source
                  chmod -R u+w source
                  cargo fmt --check --manifest-path "$PWD/source/Cargo.toml"
                  touch "$out"
                '';
            quality = pkgs.stdenv.mkDerivation {
              name = "${pname}-quality";
              src = ./.;
              inherit (package) cargoDeps;
              HOME = "$TMPDIR";
              nativeBuildInputs = [
                developmentToolchain
                pkgs.cargo-deny
                rustPlatform.cargoSetupHook
              ];
              buildPhase = ''
                runHook preBuild
                cargo clippy --frozen --all-targets --all-features -- -D warnings
                cargo deny --frozen check bans sources
                runHook postBuild
              '';
              installPhase = ''
                touch "$out"
              '';
            };
          };
        }
      );
}
