# dotfiles

Personal Nix flake for managing personal devices with Home Manager, powered by [nixos-unified](https://github.com/srid/nixos-unified).

## Setup

```bash
git clone git@github.com:citrusinesis/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
./scripts/bootstrap.sh
nix run .#activate
```

## Usage

After the first activation, these shell aliases are available:

```bash
sw              # Rebuild and switch the current host
up              # Update pins/locks, check, and switch the current host
bump            # Update flake.lock without switching
gc              # Safer GC (keeps last 5 generations + 3d)
```

`activate` follows the nixos-unified selector format:

```bash
nix run .#activate                         # Current NixOS or nix-darwin host
nix run .#activate -- '<host>'             # Named system configuration
nix run .#activate -- '<user>@'            # Local Home Manager configuration
nix run .#activate -- '<user>@<host>'      # Remote Home Manager configuration
nix run .#update                           # Update primary flake inputs
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
