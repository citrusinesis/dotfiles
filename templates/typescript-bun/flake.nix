{
  description = "TypeScript app template";

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
      pname = "bun-app";
      version = "0.1.0";
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/${pname}";
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bun
            biome
            typescript
            typescript-language-server
          ];
        };

        packages.default = pkgs.stdenv.mkDerivation {
          inherit pname version;
          src = ./.;
          nativeBuildInputs = [ pkgs.bun ];

          buildPhase = ''
            runHook preBuild
            bun build src/index.ts --outdir dist --target bun --minify
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin $out/lib/${pname}
            cp -r dist/. $out/lib/${pname}/

            cat > $out/bin/${pname} <<EOF
            #!${pkgs.runtimeShell}
            exec ${pkgs.bun}/bin/bun run $out/lib/${pname}/index.js "\$@"
            EOF

            chmod +x $out/bin/${pname}
            runHook postInstall
          '';
        };
      }
    );
}
