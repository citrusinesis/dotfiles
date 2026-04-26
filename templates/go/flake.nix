{
  description = "Go service template (vendored)";

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
      pname = "go-service";
      version = "0.1.0";
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;
      in
      {
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/${pname}";
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            (lib.hiPrio gopls)
            delve
            golangci-lint
            gofumpt
            air
            mockgen
          ];

          shellHook = ''
            if [ -f go.mod ] && [ ! -d vendor ]; then
              echo "Initializing vendor/ directory..."
              go mod vendor
            fi
          '';
        };

        packages.default = pkgs.buildGoModule {
          inherit pname version;
          src = ./.;
          vendorHash = null;

          preBuild = ''
            if [ ! -d vendor ]; then
              echo "ERROR: vendor/ directory required. Run 'go mod vendor'."
              exit 1
            fi
          '';

          subPackages = [ "./cmd/${pname}" ];
          ldflags = [
            "-s"
            "-w"
            "-X main.version=${version}"
          ];
        };
      }
    );
}
