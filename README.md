# Nix Configuration

Personal Nix flake managing NixOS and macOS systems with Home Manager, powered by [nixos-unified](https://github.com/srid/nixos-unified).

## Systems

| Host | OS | Arch | Description |
|------|----|------|-------------|
| **blender** | NixOS | x86_64 | Desktop with KDE Plasma 6, NVIDIA GPU |
| **squeezer** | macOS | aarch64 | MacBook (full Homebrew app set) |
| **juicer** | macOS | aarch64 | macOS with minimal Home Manager profile |

## Quick Start

```bash
# Activate current system (auto-detects hostname)
nix run .#activate

# Update flake inputs and activate
nix run .#update && nix run .#activate
```

### New Machine Setup

```bash
# 1. Install Nix
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# 2. Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# 3. Clone dotfiles
git clone <repo> ~/.config/dotfiles
cd ~/.config/dotfiles

# 4. Activate
nix run .#activate           # Full system (matches hostname)
nix run .#activate squeezer  # Specific Darwin config (full apps)
nix run .#activate juicer    # Specific Darwin config (minimal apps)
nix run .#activate blender   # Specific NixOS config
nix run .#activate citrus@   # Home Manager only (for Ubuntu/other Linux)
```

## Structure

```
.
├── flake.nix                    # nixos-unified flake
├── personal.nix                 # User info (git, username)
├── configurations/
│   ├── nixos/blender/           # nixosConfigurations.blender
│   ├── darwin/squeezer/         # darwinConfigurations.squeezer (full apps)
│   ├── darwin/juicer/           # darwinConfigurations.juicer (minimal apps)
│   └── home/                    # Home Manager profiles
│       ├── default/             # default profile (used on blender/squeezer)
│       ├── minimal/             # minimal profile (used on juicer)
│       └── development/         # dev-focused profile
├── modules/
│   ├── nixos/                   # NixOS modules → nixosModules.*
│   ├── darwin/                  # Darwin modules → darwinModules.*
│   ├── shared/                  # Shared modules (nix, fonts)
│   └── flake/                   # Flake-parts modules (overlays, formatter)
```

## Languages

Each language module includes runtime, LSP, and tools:

| Language | Runtime | LSP | Tools |
|----------|---------|-----|-------|
| Go | go | gopls | gofumpt, golangci-lint |
| Rust | rustc, cargo | rust-analyzer | clippy, rustfmt |
| TypeScript | nodejs | typescript-language-server | prettier |
| Python | python3 | pyright | ruff |
| Nix | - | nixd | nixfmt-rfc-style |
| YAML | - | yaml-language-server | - |
| JSON | - | vscode-langservers-extracted | - |

## macOS Apps

Managed via Homebrew in `configurations/darwin/squeezer/applications.nix` (full set) and `configurations/darwin/juicer/applications.nix` (minimal set).

## Channels

- **nixpkgs** (25.11): Stable base
- **nixpkgs-unstable**: Latest packages via `pkgs.unstable.*`
