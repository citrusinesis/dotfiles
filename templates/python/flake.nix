{
  description = "Python service template with uv-managed env and company defaults";

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
      pname = "python-service";
      version = "0.1.0";
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python312;
      in
      {
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/${pname}";
        };

        devShells.default = pkgs.mkShell {
          packages = [
            python
            pkgs.uv
            pkgs.ruff
            pkgs.black
            pkgs.pyright
          ];

          env = {
            UV_PYTHON = "${python}/bin/python";
            UV_PYTHON_DOWNLOADS = "never";
          };

          shellHook = ''
            export UV_CACHE_DIR="''${UV_CACHE_DIR:-$HOME/.cache/uv}"
            if [ ! -d .venv ]; then
              uv sync --frozen 2>/dev/null || uv sync
            fi
            export VIRTUAL_ENV="$PWD/.venv"
            export PATH="$VIRTUAL_ENV/bin:$PATH"
          '';
        };

        packages.default = python.pkgs.buildPythonApplication {
          inherit pname version;
          pyproject = true;
          src = ./.;

          build-system = with python.pkgs; [ hatchling ];

          dependencies = with python.pkgs; [
            python-dotenv
            httpx
          ];
        };
      }
    );
}
