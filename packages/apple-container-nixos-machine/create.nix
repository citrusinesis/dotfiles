{
  lib,
  pkgs,
  writeShellApplication,
  coreutils,
  findutils,
  gnugrep,
  nix,
  apple-container ? null,
}:

writeShellApplication {
  name = "apple-container-nixos-machine";

  runtimeInputs = [
    coreutils
    findutils
    gnugrep
    nix
  ]
  ++ lib.optionals (pkgs.stdenv.isDarwin && apple-container != null) [ apple-container ];

  text = ''
    usage() {
      cat <<'EOF'
    Usage: apple-container-nixos-machine [options]

    Build the NixOS container-machine rootfs, wrap it as an OCI image, and create
    an apple/container machine from it.

    Options:
      -n, --name NAME          Machine name (default: nixos)
      -t, --image IMAGE        Local image tag (default: local/nixos-machine:latest)
          --flake FLAKE        Flake ref/path (default: $NH_FLAKE or current directory)
          --package PACKAGE    Package name to build (default: apple-container-nixos-machine-rootfs)
          --platform PLATFORM  OCI platform for container build (default: host Linux arch)
          --build-mode MODE    auto, host, or container (default: auto)
          --replace            Stop and delete an existing machine with the same name
          --no-boot            Create the machine without booting it
          --no-set-default     Do not set the machine as default
      -h, --help              Show this help

    On Darwin, auto build mode builds the Linux rootfs inside nixos/nix using
    apple/container, so a separate Nix Linux builder is not required. Container
    build mode supports local flake paths and remote flake refs such as
    github:citrusinesis/dotfiles.
    EOF
    }

    case "$(uname -m)" in
      arm64|aarch64) default_platform="linux/arm64" ;;
      x86_64|amd64) default_platform="linux/amd64" ;;
      *) default_platform="linux/arm64" ;;
    esac

    machine_name="''${CONTAINER_MACHINE_NAME:-nixos}"
    image_name="''${CONTAINER_MACHINE_IMAGE:-local/nixos-machine:latest}"
    flake_ref="''${NH_FLAKE:-$PWD}"
    package_name="apple-container-nixos-machine-rootfs"
    platform="''${CONTAINER_MACHINE_PLATFORM:-$default_platform}"
    build_mode="auto"
    replace=0
    boot=1
    set_default=1

    while [ "$#" -gt 0 ]; do
      case "$1" in
        -n|--name)
          machine_name="''${2:?missing value for $1}"
          shift 2
          ;;
        -t|--image)
          image_name="''${2:?missing value for $1}"
          shift 2
          ;;
        --flake)
          flake_ref="''${2:?missing value for $1}"
          shift 2
          ;;
        --package)
          package_name="''${2:?missing value for $1}"
          shift 2
          ;;
        --platform)
          platform="''${2:?missing value for $1}"
          shift 2
          ;;
        --build-mode)
          build_mode="''${2:?missing value for $1}"
          shift 2
          ;;
        --replace)
          replace=1
          shift
          ;;
        --no-boot)
          boot=0
          shift
          ;;
        --no-set-default)
          set_default=0
          shift
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          echo "unknown option: $1" >&2
          usage >&2
          exit 2
          ;;
      esac
    done

    if ! command -v container >/dev/null 2>&1; then
      echo "container CLI not found; enable containerRuntime = \"container\" or install apple/container" >&2
      exit 1
    fi

    case "$build_mode" in
      auto|host|container) ;;
      *)
        echo "invalid --build-mode: $build_mode" >&2
        exit 2
        ;;
    esac

    if [ "$build_mode" = auto ]; then
      if [ "$(uname -s)" = Darwin ]; then
        build_mode=container
      else
        build_mode=host
      fi
    fi

    workdir="$(mktemp -d)"
    cleanup() {
      rm -rf "$workdir"
    }
    trap cleanup EXIT

    rootfs="$workdir/rootfs.tar.xz"

    copy_rootfs_from_result() {
      result_path="$1"
      tarball="$(find "$result_path/tarball" -maxdepth 1 -type f -name '*.tar*' | head -n 1)"
      if [ -z "$tarball" ]; then
        echo "rootfs tarball not found under $result_path/tarball" >&2
        exit 1
      fi
      cp "$tarball" "$rootfs"
    }

    if [ "$build_mode" = host ]; then
      echo "==> Building rootfs on host: $flake_ref#$package_name"
      out_link="$workdir/rootfs-result"
      nix build "$flake_ref#$package_name" --out-link "$out_link"
      copy_rootfs_from_result "$out_link"
    else
      echo "==> Building rootfs inside nixos/nix container: $flake_ref#$package_name"

      build_ref="$flake_ref"
      container_args=(
        run
        --rm
        --volume "$workdir:/out"
        --env "PACKAGE_NAME=$package_name"
      )

      case "$flake_ref" in
        /*)
          flake_path="$flake_ref"
          build_ref="/work"
          container_args+=(--volume "$flake_path:/work")
          ;;
        path:/*)
          flake_path="''${flake_ref#path:}"
          build_ref="/work"
          container_args+=(--volume "$flake_path:/work")
          ;;
        .|./*)
          flake_path="$(cd "$flake_ref" && pwd)"
          build_ref="/work"
          container_args+=(--volume "$flake_path:/work")
          ;;
      esac

      container_args+=(
        --env "FLAKE_REF=$build_ref"
        nixos/nix:latest
      )

      # shellcheck disable=SC2016
      container "''${container_args[@]}" \
        sh -euc '
          result=$(nix --extra-experimental-features "nix-command flakes" \
            build "$FLAKE_REF#$PACKAGE_NAME" --no-link --print-out-paths)
          tarball=$(find "$result/tarball" -maxdepth 1 -type f -name "*.tar*" | head -n 1)
          if [ -z "$tarball" ]; then
            echo "rootfs tarball not found under $result/tarball" >&2
            exit 1
          fi
          cp "$tarball" /out/rootfs.tar.xz
        '
    fi

    cat > "$workdir/Dockerfile" <<'EOF'
    FROM scratch
    ADD rootfs.tar.xz /
    ENV container=container
    STOPSIGNAL SIGRTMIN+3
    ENTRYPOINT ["/sbin/init"]
    EOF

    echo "==> Building OCI image: $image_name"
    container build --platform "$platform" -t "$image_name" "$workdir"

    if container machine inspect "$machine_name" >/dev/null 2>&1; then
      if [ "$replace" -eq 1 ]; then
        echo "==> Replacing existing machine: $machine_name"
        container machine stop "$machine_name" >/dev/null 2>&1 || true
        container machine delete "$machine_name"
      else
        echo "machine already exists: $machine_name" >&2
        echo "rerun with --replace to recreate it" >&2
        exit 1
      fi
    fi

    create_args=(machine create "$image_name" --name "$machine_name")
    if [ "$set_default" -eq 1 ]; then
      create_args+=(--set-default)
    fi
    if [ "$boot" -eq 0 ]; then
      create_args+=(--no-boot)
    fi

    echo "==> Creating container machine: $machine_name"
    container "''${create_args[@]}"
  '';

  meta = {
    description = "Build and create a NixOS Apple container machine";
    platforms = lib.platforms.darwin;
  };
}
