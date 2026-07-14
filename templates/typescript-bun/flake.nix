{
  description = "TypeScript app template with Bun and Biome";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      bun2nix,
      nixpkgs,
      flake-utils,
    }:
    let
      pname = "bun-app";
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
            overlays = [ bun2nix.overlays.default ];
          };
          package = pkgs.bun2nix.writeBunApplication {
            inherit pname version;
            src = ./.;
            bunInstallFlags = [ "--frozen-lockfile" ];
            bunDeps = pkgs.bun2nix.fetchBunDeps {
              bunNix = ./bun.nix;
            };
            buildPhase = ''
              bun build src/index.ts --outdir dist --target bun --minify
            '';
            startScript = ''
              bun run dist/index.js "$@"
            '';
          };
        in
        {
          apps.default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/${pname}";
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              bun
              pkgs.bun2nix
              biome
              typescript
              typescript-language-server
            ];
          };

          packages.default = package;

          checks = {
            default = package;
            lint = pkgs.runCommand "${pname}-lint" { nativeBuildInputs = [ pkgs.biome ]; } ''
              mkdir source
              cp ${./biome.json} source/biome.json
              cp ${./.gitignore} source/.gitignore
              cp -R ${./src} source/src
              cd source
              biome check src biome.json
              touch "$out"
            '';
            lock = pkgs.runCommand "${pname}-lock" { nativeBuildInputs = [ pkgs.bun2nix ]; } ''
              bun2nix --lock-file ${./bun.lock} > generated-bun.nix
              diff -u ${./bun.nix} generated-bun.nix
              touch "$out"
            '';
            types = pkgs.runCommand "${pname}-types" { nativeBuildInputs = [ pkgs.typescript ]; } ''
              mkdir source
              cp ${./tsconfig.json} source/tsconfig.json
              cp -R ${./src} source/src
              cd source
              tsc --noEmit --project tsconfig.json
              touch "$out"
            '';
          };
        }
      );
}
