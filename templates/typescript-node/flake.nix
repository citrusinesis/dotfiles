{
  description = "TypeScript app template with Node, pnpm, and Biome";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      pname = "node-app";
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
          pkgs = import nixpkgs { inherit system; };
          pnpm = pkgs.pnpm_9;
          package = pkgs.stdenvNoCC.mkDerivation {
            inherit pname version;
            src = ./.;
            pnpmDeps = pkgs.fetchPnpmDeps {
              inherit pname version pnpm;
              src = ./.;
              fetcherVersion = 3;
              hash = "sha256-iQ75ySHfI7fmTpXy8yKVUQhtcuhEvn5ECA0JsVg7upY=";
            };
            nativeBuildInputs = [
              pkgs.makeWrapper
              pkgs.nodejs
              pkgs.pnpmConfigHook
              pnpm
              pkgs.typescript
            ];

            buildPhase = ''
              runHook preBuild
              pnpm run build
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p "$out/lib/${pname}"
              cp -r dist package.json "$out/lib/${pname}/"
              if [ -d node_modules ]; then
                cp -r node_modules "$out/lib/${pname}/"
              fi
              makeWrapper ${pkgs.nodejs}/bin/node "$out/bin/${pname}" \
                --add-flags "$out/lib/${pname}/dist/index.js"
              runHook postInstall
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
              nodejs
              pnpm_9
              biome
              nix-update
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
