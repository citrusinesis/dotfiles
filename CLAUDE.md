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
│       ├── default.nix       # Package lists and home settings
│       └── programs/         # Program-specific configurations
│           ├── default.nix   # Import aggregator
│           ├── direnv.nix    # direnv configuration
│           ├── git.nix       # Git and delta configuration
│           ├── kitty.nix     # Kitty terminal configuration
│           ├── neovim.nix    # Neovim with LSP and plugins
│           ├── podman.nix    # Podman container runtime configuration
│           ├── ssh.nix       # SSH client configuration
│           ├── starship.nix  # Shell prompt configuration
│           ├── vscode.nix    # VSCode settings and extensions
│           └── zsh.nix       # Zsh shell configuration
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

### System Rebuilds
```bash
# NixOS (blender) - requires sudo
sudo nixos-rebuild switch --flake .#blender

# macOS (squeezer)
darwin-rebuild switch --flake .#squeezer
```

### Development & Testing
```bash
# Enter development shell with formatting tools
nix develop

# Format Nix files
nixpkgs-fmt **/*.nix

# Check flake syntax and dependencies
nix flake check
```

## Conventions & Patterns

### File Organization
- **Modular imports**: Each configuration file imports its dependencies via `imports = [ ... ]`
- **Personal data**: Centralized in `personal.nix` and imported where needed
- **Platform-specific logic**: Use `lib.mkIf pkgs.stdenv.isDarwin` / `pkgs.stdenv.isLinux`
- **Program configurations**: Separate files in `programs/` directories

### Naming Conventions
- **Hosts**: Lowercase, descriptive names (`blender`, `squeezer`)
- **Users**: Consistent usernames across systems (from `personal.nix`)
- **Files**: kebab-case for multi-word names

### Package Management Strategy
- **Multiple channels**: Stable base (`nixpkgs` 25.11), unstable overlay (`nixpkgs-unstable`)
- **System packages**: Minimal essentials in `modules/base.nix` (Linux) or `modules/darwin/base.nix` (macOS)
- **User packages**: Development tools and CLI utilities in `home/citrus/default.nix`
- **Package access**: `pkgs.unstable.package-name` for latest versions

### Code Style
- **Indentation**: 2 spaces
- **Comments**: Only for complex configurations; avoid comments that duplicate code
- **Module structure**: Standard `{ config, lib, pkgs, ... }:` parameter pattern
- **Imports first**: Always list imports at the top of configuration files
- **Module responsibility**: Each module should only configure what its name implies

### Home Manager Integration
- **User isolation**: Each user gets their own home configuration
- **Program modules**: Split configurations into focused program files
- **State version**: Pin to release version (`"25.11"`)

### Hardware & System Specific
- **Conditional configs**: Use `lib.mkIf` for platform/hardware-specific settings
- **Hardware detection**: Reference hardware via `hardware-configuration.nix`
- **Performance optimizations**: Document complex settings (e.g., GPU, audio, networking)

## Key Features

- **Multi-channel package management** with stable (25.11) and unstable
- **Cross-platform** shared shell configuration via `modules/shell.nix`
- **Development environment** with Nix LSP (nil, nixd), formatters, and language runtimes
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
