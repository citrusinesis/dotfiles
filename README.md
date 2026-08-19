# dotfiles

Personal Nix flake for managing personal devices with Home Manager, powered by [nixos-unified](https://github.com/srid/nixos-unified).

## New Machine Setup

```bash
# 1. Clone the repo
git clone <repo> ~/.config/dotfiles
cd ~/.config/dotfiles

# 2. Run setup (installs Lix + Homebrew on macOS)
./scripts/bootstrap.sh

# 3. Activate through nixos-unified
nix run .#activate
```

## Usage

After the first activation, the shell aliases and `nh` utilities are available.

```bash
sw              # Rebuild and switch the current host
up              # Update pins/locks, check, and switch the current host
bump            # Update flake.lock without switching
gc              # Safer GC (keeps last 5 generations + 3d)

nh search <pkg> # Fast nixpkgs search via search.nixos.org

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

## Apple Container

Apple Container is opt-in per Home Manager profile:

```nix
home-manager.users.${config.system.primaryUser}.dotfiles.home.appleContainer.enable = true;
```

Its upstream version and source hash are pinned independently in the overlay
because nixpkgs can lag behind [apple/container](https://github.com/apple/container)
releases. `up` bumps it automatically on macOS; to bump it manually:

```bash
nix run .#update-pinned-packages
```

Podman is also opt-in per Home Manager profile:

```nix
dotfiles.home.podman.enable = true;
```

## Homebrew Policy

Homebrew is fully declarative on macOS. Activation uses `cleanup = "zap"`, so
formulae and casks not declared in the Nix configuration are removed, including
files associated with undeclared casks. Add software to the relevant Darwin
configuration before the next `sw`; the destructive cleanup is intentional.

## Home profiles

- `minimal`: CLI, shell, Git, direnv, and Nix tooling
- `headless`: minimal plus Nixvim
- `headless-development`: headless plus languages, containers, Kubernetes, and agents
- `development`: headless-development plus GUI editors, terminals, and desktop tools
- `default`: alias of development
