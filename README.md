# dotfiles

Personal Nix flake for managing personal devices with Home Manager, powered by [nixos-unified](https://github.com/srid/nixos-unified).

## New Machine Setup

```bash
# 1. Clone the repo
git clone <repo> ~/.config/dotfiles
cd ~/.config/dotfiles

# 2. Run setup (installs Lix + Homebrew on macOS)
./scripts/bootstrap.sh

# 3. Activate (first run uses nixos-unified app since `nh` is not yet on PATH)
nix run .#activate
```

## Usage

After the first activation, the shell aliases and `nh` utilities are available.

```bash
sw              # Rebuild and switch the current host
up              # Update pins/locks, check, and switch the current host
bump            # Update flake.lock without switching
gc              # Safer GC (keeps last 5 generations + 3d)

nh search <pkg> # Fast nixpkgs search via nix-index

nix flake check # Validate evaluation and checks
```

Equivalent explicit commands:

```bash
nix run .#activate          # Match current hostname
nix run .#activate blender  # NixOS WSL host
nix run .#activate mixer    # macOS default profile
nix run .#activate juicer   # macOS development profile
nix run .#update            # Update nixpkgs, Home Manager, and nix-darwin only
```

## Container Runtime

Each darwin host selects exactly one container runtime in its configuration:

```nix
containerRuntime = "container"; # apple/container | "orbstack" | "podman"
```

`container` reuses the nixpkgs package, while its upstream version and source hash are pinned independently in the overlay because nixpkgs can lag behind [apple/container](https://github.com/apple/container) releases. `up` bumps it automatically on macOS; to bump it manually:

```bash
nix run .#update-pinned-packages
```

## Project Templates

Bootstrap a project from this flake's templates:

e.g. Rust project
```bash
mkdir example-rust-service && cd example-rust-service
nix flake init -t github:citrusinesis/dotfiles#rust
```

All templates expose `packages.default`, `apps.default`, `checks`, and a
`devShell`. Their Nix locks and language dependencies are intentionally updated
separately:

```bash
./scripts/update-templates.sh              # Nix flake locks only
./scripts/update-template-dependencies.sh  # Language dependency locks
```

## Home profiles

- `minimal`: CLI, shell, Git, direnv, and Nix tooling
- `headless`: minimal plus Nixvim
- `headless-development`: headless plus languages, containers, Kubernetes, and agents
- `development`: headless-development plus GUI editors, terminals, and desktop tools
- `default`: alias of development
