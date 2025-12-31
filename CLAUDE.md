# CLAUDE.md - Nix Configuration Project

## Project Overview

This is a personal Nix configuration flake managing both NixOS and macOS (Darwin) systems using Home Manager for user-specific configurations.

**Systems:**
- `blender` - x86_64 NixOS desktop with KDE Plasma 6, NVIDIA GPU, gaming setup
- `squeezer` - aarch64 macOS system

## Project Structure

```
.
├── flake.nix                 # Main flake configuration with inputs/outputs
├── lib.nix                   # Helper functions for system configuration
├── personal.nix              # Personal information (git, user, timezone)
├── home/                     # Home Manager configurations per user
│   └── citrus/               # Main user configuration
│       ├── default.nix       # Entry point (imports only)
│       ├── cli/              # CLI tools with home-manager program configs
│       │   ├── bat.nix       # Syntax highlighting (catppuccin theme)
│       │   ├── btop.nix      # System monitor (catppuccin, vim keys)
│       │   ├── eza.nix       # Modern ls (icons, git)
│       │   ├── fd.nix        # File finder
│       │   ├── packages.nix  # Additional CLI packages
│       │   └── ripgrep.nix   # Grep replacement
│       ├── dev/              # Development tools
│       │   ├── direnv.nix    # Directory environments
│       │   ├── git.nix       # Git and delta configuration
│       │   ├── kubernetes.nix # kubectl, minikube
│       │   └── podman.nix    # Container runtime
│       ├── editors/          # Text editors
│       │   ├── neovim.nix    # Neovim with native LSP (0.11+)
│       │   └── vscode.nix    # VSCode settings and extensions
│       ├── languages/        # Programming languages (runtime + LSP + tools)
│       │   ├── go.nix        # Go, gopls, gofumpt
│       │   ├── json.nix      # vscode-langservers-extracted
│       │   ├── nix.nix       # nixd, nixfmt-rfc-style
│       │   ├── python.nix    # Python 3, pyright, ruff
│       │   ├── rust.nix      # Rust, rust-analyzer
│       │   ├── typescript.nix # Node.js, TypeScript, typescript-language-server
│       │   └── yaml.nix      # yaml-language-server
│       ├── misc/             # Miscellaneous
│       │   ├── apps.nix      # Linux GUI apps (slack, obsidian, firefox)
│       │   ├── opencode.nix  # OpenCode AI configuration
│       │   └── ssh.nix       # SSH client configuration
│       ├── shell/            # Shell configuration
│       │   ├── fzf.nix       # Fuzzy finder
│       │   ├── starship.nix  # Shell prompt
│       │   ├── tmux.nix      # Terminal multiplexer
│       │   └── zsh.nix       # Zsh with oh-my-zsh
│       └── terminals/        # Terminal emulators
│           ├── ghostty.nix   # Ghostty (catppuccin theme)
│           └── kitty.nix     # Kitty terminal
├── hosts/                    # Host-specific system configurations
│   ├── blender/              # NixOS desktop
│   │   ├── default.nix       # Host configuration
│   │   └── hardware-configuration.nix
│   └── squeezer/             # macOS system
│       ├── default.nix       # Host configuration
│       └── applications.nix  # Homebrew casks and Mac App Store apps
├── modules/                  # Reusable configuration modules
│   ├── shell.nix             # Shared shell aliases and environment variables
│   ├── nix.nix               # Nix daemon and package manager settings
│   ├── fonts.nix             # System fonts configuration
│   ├── base.nix              # Base NixOS system settings (Linux only)
│   ├── desktop.nix           # KDE Plasma desktop (Linux only)
│   ├── audio.nix             # PipeWire audio configuration (Linux only)
│   ├── networking.nix        # Network and Tailscale setup (Linux only)
│   ├── nvidia.nix            # NVIDIA GPU configuration (Linux only)
│   ├── i18n.nix              # Korean input method (Linux only)
│   ├── power.nix             # Power management (Linux only)
│   └── darwin/               # macOS-specific modules
│       ├── base.nix          # Base Darwin settings
│       ├── homebrew.nix      # Homebrew package manager
│       └── system-defaults.nix # macOS system preferences
├── profiles/                 # System profiles aggregating modules
│   ├── workstation.nix       # NixOS workstation profile
│   └── darwin-workstation.nix # macOS workstation profile
└── overlays/                 # Package overlays
    └── default.nix           # Channel overlays (unstable)
```

## Build Commands

```bash
# NixOS (blender) - requires sudo
sudo nixos-rebuild switch --flake .#blender

# macOS (squeezer)
darwin-rebuild switch --flake .#squeezer

# Check flake syntax
nix flake check
```

## Conventions & Patterns

### File Organization
- **One element per file**: Each program/tool gets its own `.nix` file
- **Category folders**: Group related configs (cli, dev, editors, languages, shell, terminals, misc)
- **Modular imports**: Each folder has a `default.nix` that imports all files in that folder
- **Personal data**: Centralized in `personal.nix` and imported where needed
- **Platform-specific logic**: Use `lib.mkIf pkgs.stdenv.isDarwin` / `pkgs.stdenv.isLinux`

### Naming Conventions
- **Hosts**: Lowercase, descriptive names (`blender`, `squeezer`)
- **Users**: Consistent usernames across systems (from `personal.nix`)
- **Files**: One file per program, named after the program (e.g., `git.nix`, `neovim.nix`)

### Package Management Strategy
- **Multiple channels**: Stable base (`nixpkgs` 25.11), unstable overlay (`nixpkgs-unstable`)
- **System packages**: Minimal essentials in `modules/base.nix` (Linux) or `modules/darwin/base.nix` (macOS)
- **User packages**: Organized by category in `home/citrus/` subfolders
- **Package access**: `pkgs.unstable.package-name` for latest versions

### Code Style
- **Indentation**: 2 spaces
- **Comments**: Only where context is genuinely needed; avoid comments that duplicate code
- **Module structure**: Standard `{ config, lib, pkgs, ... }:` parameter pattern
- **Imports first**: Always list imports at the top of configuration files
- **Theme**: Catppuccin Mocha everywhere (terminals, editors, CLI tools)

### Home Manager Integration
- **User isolation**: Each user gets their own home configuration
- **Program modules**: Use `programs.<name>.enable` with configuration where available
- **State version**: Pin to release version (`"25.11"`)
- **Zsh ordering**: Use `lib.mkOrder 550` for `initContent` (after plugins load)

### Neovim LSP Setup
- Uses Neovim 0.11+ native LSP configuration
- LSP servers configured via `vim.lsp.config()` and `vim.lsp.enable()` in init.lua
- Language servers installed via `languages/*.nix` modules

## Key Features

- **Multi-channel package management** with stable (25.11) and unstable
- **Cross-platform** shared shell configuration via `modules/shell.nix`
- **Language support** with LSP, formatters, and linters per language
- **Catppuccin Mocha** theme across all tools
- **Audio optimization** with PipeWire suspension fixes (Linux)
- **Network optimization** with Tailscale exit node setup (Linux)
- **macOS integration** with Homebrew casks and system defaults

## Making Changes

1. **Edit relevant configuration files** following existing patterns
2. **Test changes** with `nix flake check` for syntax
3. **Apply changes** with appropriate rebuild command
4. **Verify functionality** after rebuild completes

## Dependencies

- Nix with flakes enabled
- Home Manager (release-25.11)
- nix-darwin (nix-darwin-25.11) for macOS
- systemd-boot for NixOS
