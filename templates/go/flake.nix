{
  description = "Go service template";

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
    flake-utils.lib.eachSystem
      [
        "aarch64-darwin"
        "x86_64-linux"
      ]
      (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          inherit (pkgs) lib;
          package = pkgs.buildGoModule {
            inherit pname version;
            src = ./.;
            vendorHash = null;
            subPackages = [ "./cmd/${pname}" ];
            ldflags = [
              "-s"
              "-w"
              "-X main.version=${version}"
            ];
          };
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
          };

          packages.default = package;

          checks = {
            default = package;
            formatting = pkgs.runCommand "${pname}-formatting" { nativeBuildInputs = [ pkgs.go ]; } ''
              unformatted="$(gofmt -l ${./.})"
              if [ -n "$unformatted" ]; then
                printf 'Unformatted Go files:\n%s\n' "$unformatted" >&2
                exit 1
              fi
              touch "$out"
            '';
            tests = pkgs.runCommand "${pname}-tests" { nativeBuildInputs = [ pkgs.go ]; } ''
              cp -R ${./.} source
              chmod -R u+w source
              cd source
              export HOME="$TMPDIR"
              export GOCACHE="$TMPDIR/go-cache"
              go test ./...
              touch "$out"
            '';
            lint =
              pkgs.runCommand "${pname}-lint"
                {
                  nativeBuildInputs = [
                    pkgs.go
                    pkgs.golangci-lint
                  ];
                }
                ''
                  cp -R ${./.} source
                  chmod -R u+w source
                  cd source
                  export HOME="$TMPDIR"
                  export GOCACHE="$TMPDIR/go-cache"
                  export GOLANGCI_LINT_CACHE="$TMPDIR/golangci-lint-cache"
                  golangci-lint run ./...
                      touch "$out"
                '';
          };
        }
      );
}
