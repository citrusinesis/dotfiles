# Nix Configuration

Personal Nix flake managing NixOS and macOS systems with Home Manager, powered by [nixos-unified](https://github.com/srid/nixos-unified).

## Systems

| Host | OS | Arch | Description |
|------|----|------|-------------|
| **blender** | NixOS | x86_64 | Desktop with KDE Plasma 6, NVIDIA GPU |
| **squeezer** | macOS | aarch64 | MacBook |

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
nix run .#activate squeezer  # Specific Darwin config
nix run .#activate blender   # Specific NixOS config
nix run .#activate citrus@   # Home Manager only (for Ubuntu/other Linux)
```

## Structure

```
.
├── flake.nix                    # nixos-unified flake
├── personal.nix                 # User info (git, username)
├── configurations/
│   ├── nixos/blender/           # NixOS config → nixosConfigurations.blender
│   ├── darwin/squeezer/         # Darwin config → darwinConfigurations.squeezer
│   └── home/citrus/             # Home Manager → homeConfigurations.citrus
│       ├── cli/                 # bat, eza, btop, ripgrep, fd
│       ├── dev/                 # git, direnv, podman, kubernetes
│       ├── editors/             # neovim, vscode
│       ├── languages/           # go, rust, typescript, python, nix
│       ├── misc/                # ssh, apps
│       ├── shell/               # zsh, starship, fzf, tmux
│       └── terminals/           # kitty, ghostty
├── modules/
│   ├── nixos/                   # NixOS modules → nixosModules.*
│   ├── darwin/                  # Darwin modules → darwinModules.*
│   ├── shared/                  # Shared modules (nix, fonts, shell)
│   └── flake/                   # Flake-parts modules (overlays)
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

Managed via Homebrew in `configurations/darwin/squeezer/applications.nix`.

## Channels

- **nixpkgs** (25.11): Stable base
- **nixpkgs-unstable**: Latest packages via `pkgs.unstable.*`
