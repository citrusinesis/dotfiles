{
  description = "Go service template with buildGoModule";

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
      in
      {
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/${pname}";
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            (pkgs.lib.hiPrio gopls)
            delve
            golangci-lint
            go-tools
            gomodifytags
            gotests
            gotools
            impl
          ];
        };

        packages.default = pkgs.buildGoModule {
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
      }
    );
}
