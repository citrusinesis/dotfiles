{ config, lib, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    stdlib = ''
      # Import common layout functions
      source "${pkgs.direnv}/share/direnv/direnvrc"

      # Extend the default "use_nix" function to add flake support
      use_flake() {
        watch_file flake.nix
        watch_file flake.lock
        eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile" "''${1:-.}")"
      }

      # Layout for Python projects
      layout_python() {
        local python="''${1:-python}"
        local venvdir="''${2:-$(direnv_layout_dir)/python-venv}"

        if [[ ! -d "$venvdir" ]]; then
          echo "Creating Python virtual environment in $venvdir..."
          $python -m venv "$venvdir"
        fi

        source "$venvdir/bin/activate"

        # Register the Python virtual environment's exit hook
        direnv_load _venv_hook
      }

      _venv_hook() {
        if [[ -n "$VIRTUAL_ENV" ]]; then
          export PYTHONPATH="$VIRTUAL_ENV/lib/python$PYTHON_VERSION/site-packages:$PYTHONPATH"
        fi
      }

      # Layout for Node.js projects
      layout_node() {
        local nodemodules="$(direnv_layout_dir)/node_modules"
        PATH_add "$nodemodules/.bin"
        export NODE_PATH="$NODE_PATH:$nodemodules"
      }

      # Improved nix-shell integration
      use_nix_shell() {
        local shell_file="''${1:-shell.nix}"
        watch_file "$shell_file"

        if [[ ! -f "$shell_file" ]]; then
          echo "No shell.nix found, falling back to default.nix"
          shell_file="default.nix"
        fi

        if [[ ! -f "$shell_file" ]]; then
          echo "No default.nix found, creating minimal shell.nix"
          cat > shell.nix <<EOF
      with import <nixpkgs> {};
      mkShell {
        buildInputs = [
          # Add packages here
        ];
      }
      EOF
        fi

        use nix -s "$shell_file"
      }

      # Golang project support
      layout_go() {
        local gopath="$(direnv_layout_dir)/go"
        export GOPATH="$gopath"
        PATH_add "$gopath/bin"
      }

      # Rust project support
      layout_rust() {
        local cargo_dir="$(direnv_layout_dir)/cargo"
        export CARGO_HOME="$cargo_dir"
        PATH_add "$cargo_dir/bin"
      }

      # Log when entering and exiting directories
      export DIRENV_LOG_FORMAT="$(tput setaf 3)direnv: %s$(tput sgr0)"
    '';

    config = {
      global = {
        load_dotenv = true;
        strict_env = true;
        warn_timeout = "5m";
      };
    };
  };

  home.activation.direnvDirectories = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/direnv
  '';

  home.packages = with pkgs; [
    nix-direnv
  ];
}
