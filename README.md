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

After the first activation, `nh` and the shell aliases are available.

```bash
rb              # Rebuild current host (nh darwin/os switch, auto-detect)
rbh             # Home Manager only
up              # Flake update + rebuild + diff preview
bump            # Just bump flake.lock
gc              # Safer GC (keeps last 5 generations + 3d)

nh search <pkg> # Fast nixpkgs search via nix-index

nix flake check # Validate evaluation and checks
```

These are fallback command.

```bash
nix run .#activate          # Match current hostname
nix run .#activate blender  # NixOS desktop
nix run .#activate mixer    # macOS default profile
nix run .#activate juicer   # macOS development profile
nix run .#update            # Just bump flake.lock
```

## Project Templates

Bootstrap a project from this flake's templates:

e.g. Rust project
```bash
mkdir example-rust-service && cd example-rust-service
nix flake init -t github:citrusinesis/dotfiles#rust
```
