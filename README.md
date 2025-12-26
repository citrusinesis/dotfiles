# Nix Configuration

Personal Nix flake managing NixOS and macOS systems with Home Manager.

## Systems

| Host | OS | Arch | Description |
|------|----|------|-------------|
| **blender** | NixOS | x86_64 | Desktop with KDE Plasma 6, NVIDIA GPU |
| **squeezer** | macOS | aarch64 | MacBook |

## Quick Start

### Rebuild

```bash
# NixOS
sudo nixos-rebuild switch --flake .#blender

# macOS
darwin-rebuild switch --flake .#squeezer
```

### Development

```bash
# Enter dev shell
nix develop

# Format files
nixpkgs-fmt **/*.nix

# Check syntax
nix flake check
```

## Structure

```
.
├── flake.nix           # Flake inputs/outputs
├── lib.nix             # Helper functions
├── personal.nix        # User info (git, username)
├── home/citrus/        # Home Manager config
│   ├── default.nix     # User packages
│   └── programs/       # Program configs (git, zsh, neovim, etc.)
├── hosts/              # Host-specific configs
│   ├── blender/        # NixOS desktop
│   └── squeezer/       # macOS
├── modules/            # Reusable modules
│   ├── shell.nix       # Shared shell config
│   ├── base.nix        # NixOS base
│   └── darwin/         # macOS modules
├── profiles/           # System profiles
└── overlays/           # Package overlays (unstable channel)
```

## Packages

### User Packages (home/citrus/default.nix)

- **Terminal**: tmux, zellij
- **Nix tools**: nil, nixd, nixfmt-rfc-style
- **CLI**: ripgrep, fd, jq, bat, eza, fzf, btop
- **Languages**: python3, nodejs, go, rust
- **Containers**: podman, minikube, kubectl
- **Utils**: dust, duf, procs, gh

### macOS Apps (hosts/squeezer/applications.nix)

Chrome, Firefox, VS Code, Slack, Obsidian, Raycast, Ghostty, Tailscale, etc.

## Channels

- **nixpkgs** (25.11): Stable base
- **nixpkgs-unstable**: Latest packages via `pkgs.unstable.*`
