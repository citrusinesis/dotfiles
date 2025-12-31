# Nix Configuration

Personal Nix flake managing NixOS and macOS systems with Home Manager.

## Systems

| Host | OS | Arch | Description |
|------|----|------|-------------|
| **blender** | NixOS | x86_64 | Desktop with KDE Plasma 6, NVIDIA GPU |
| **squeezer** | macOS | aarch64 | MacBook |

## Quick Start

```bash
# NixOS
sudo nixos-rebuild switch --flake .#blender

# macOS
darwin-rebuild switch --flake .#squeezer
```

## Structure

```
.
├── flake.nix           # Flake inputs/outputs
├── lib.nix             # Helper functions
├── personal.nix        # User info (git, username)
├── home/citrus/        # Home Manager config
│   ├── cli/            # bat, eza, btop, ripgrep, fd
│   ├── dev/            # git, direnv, podman, kubernetes
│   ├── editors/        # neovim, vscode
│   ├── languages/      # go, rust, typescript, python, nix (runtime + LSP)
│   ├── misc/           # ssh, opencode, apps
│   ├── shell/          # zsh, starship, fzf, tmux
│   └── terminals/      # kitty, ghostty
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

## Languages

Each language module (`home/citrus/languages/`) includes runtime, LSP, and tools:

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

Managed via Homebrew in `hosts/squeezer/applications.nix`:

Chrome, Firefox, VS Code, Slack, Obsidian, Element, Raycast, Ghostty, Tailscale, etc.

## Channels

- **nixpkgs** (25.11): Stable base
- **nixpkgs-unstable**: Latest packages via `pkgs.unstable.*`
