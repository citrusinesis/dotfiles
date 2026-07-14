{
  description = "Python service template with uv2nix, BasedPyright, and Ruff";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pyproject-nix,
      uv2nix,
      pyproject-build-systems,
    }:
    let
      workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };
      workspaceOverlay = workspace.mkPyprojectOverlay {
        sourcePreference = "wheel";
      };
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
          python = pkgs.python313;
          basePythonSet = pkgs.callPackage pyproject-nix.build.packages {
            inherit python;
          };
          pythonSet = basePythonSet.overrideScope (
            pkgs.lib.composeManyExtensions [
              pyproject-build-systems.overlays.wheel
              workspaceOverlay
            ]
          );
          editablePythonSet = pythonSet.overrideScope (
            workspace.mkEditablePyprojectOverlay {
              root = "$REPO_ROOT";
            }
          );
          applicationVirtualenv = pythonSet.mkVirtualEnv "python-service-env" workspace.deps.default;
          checkVirtualenv = pythonSet.mkVirtualEnv "python-service-check-env" workspace.deps.all;
          developmentVirtualenv = editablePythonSet.mkVirtualEnv "python-service-dev-env" workspace.deps.all;
          inherit (pkgs.callPackages pyproject-nix.build.util { }) mkApplication;
          package = mkApplication {
            venv = applicationVirtualenv;
            package = pythonSet."python-service";
          };
        in
        {
          apps.default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/python-service";
          };

          devShells.default = pkgs.mkShell {
            packages = [
              developmentVirtualenv
              pkgs.uv
            ];

            env = {
              UV_NO_SYNC = "1";
              UV_PYTHON = editablePythonSet.python.interpreter;
              UV_PYTHON_DOWNLOADS = "never";
            };

            shellHook = ''
              unset PYTHONPATH
              export REPO_ROOT="$PWD"
            '';
          };

          packages.default = package;

          checks = {
            default = package;
            lint = pkgs.runCommand "python-service-lint" { nativeBuildInputs = [ checkVirtualenv ]; } ''
              ruff check --no-cache ${./.}/src ${./.}/tests
              ruff format --no-cache --check ${./.}/src ${./.}/tests
              touch "$out"
            '';
            lock =
              pkgs.runCommand "python-service-lock"
                {
                  nativeBuildInputs = [ pkgs.uv ];
                  HOME = "$TMPDIR";
                  UV_CACHE_DIR = "$TMPDIR/uv-cache";
                  UV_OFFLINE = "1";
                  UV_PYTHON = "${python}/bin/python";
                  UV_PYTHON_DOWNLOADS = "never";
                }
                ''
                  cp ${./pyproject.toml} pyproject.toml
                  cp ${./uv.lock} uv.lock
                  uv lock --check
                  touch "$out"
                '';
            tests = pkgs.runCommand "python-service-tests" { nativeBuildInputs = [ checkVirtualenv ]; } ''
              cp -R ${./.} source
              chmod -R u+w source
              cd source
              pytest
              touch "$out"
            '';
            types = pkgs.runCommand "python-service-types" { nativeBuildInputs = [ checkVirtualenv ]; } ''
              cp -R ${./.} source
              chmod -R u+w source
              cd source
              export PYTHONPATH="$PWD/src"
              basedpyright --pythonpath ${checkVirtualenv}/bin/python
              touch "$out"
            '';
          };
        }
      );
}
