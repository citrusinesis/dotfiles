# CLAUDE.md - Nix Configuration Project

## Project Overview

This repository is a personal Nix flake for managing both NixOS and macOS systems, with Home Manager handling user-level configuration.

Core stack:
- `nixpkgs` `25.11`
- `nixpkgs-unstable` overlay for newer packages
- `nix-darwin`
- `home-manager`
- `nixos-unified`
- `git-hooks.nix`

## Systems

- `blender` - x86_64 NixOS desktop with KDE Plasma 6, NVIDIA, and the `default` Home Manager profile
- `mixer` - aarch64 macOS machine with the `default` Home Manager profile and the smaller Homebrew app set
- `juicer` - aarch64 macOS machine with the `development` Home Manager profile and the broader Homebrew app set

## Repository Structure

```text
.
|- flake.nix
|- personal.nix
|- configurations/
|  |- nixos/
|  |  `- blender/
|  |     |- default.nix
|  |     `- hardware-configuration.nix
|  |- darwin/
|  |  |- mixer/
|  |  |  |- default.nix
|  |  |  `- applications.nix
|  |  `- juicer/
|  |     |- default.nix
|  |     `- applications.nix
|  `- home/
|     |- minimal/default.nix
|     |- development/default.nix
|     `- default/default.nix
`- modules/
   |- flake/
   |  |- git-hooks.nix
   |  |- overlays.nix
   |  `- toplevel.nix
   |- shared/
   |  |- default.nix
   |  |- fonts.nix
   |  `- nix.nix
   |- nixos/
   |  |- default.nix
   |  |- minimal.nix
   |  |- graphical.nix
   |  `- system/
   |     |- audio.nix
   |     |- base.nix
   |     |- desktop.nix
   |     |- i18n.nix
   |     |- networking.nix
   |     |- nvidia.nix
   |     `- power.nix
   |- darwin/
   |  |- default.nix
   |  |- base.nix
   |  |- homebrew.nix
   |  `- system-defaults.nix
   `- home/
      |- default.nix
      |- development.nix
      |- minimal.nix
      |- cli/
      |- dev/
      |- editors/
      |- languages/
      |- misc/
      |- shell/
      `- terminals/
```

## How It Fits Together

- `flake.nix` is intentionally small and delegates output generation to `nixos-unified.lib.mkFlake`
- `modules/flake/toplevel.nix` imports the `nixos-unified` flake modules and enables auto-wiring
- `configurations/*/*/default.nix` files are host/profile entrypoints
- `modules/*` contain reusable system and Home Manager building blocks
- `personal.nix` is the single source of truth for username, git identity, and timezone

## Important Composition Patterns

### Host configs
- `configurations/nixos/blender/default.nix` imports `self.nixosModules.default` and Home Manager
- `configurations/darwin/mixer/default.nix` imports `self.darwinModules.default`, `./applications.nix`, and Home Manager
- `configurations/darwin/juicer/default.nix` does the same, but points Home Manager at the `development` profile

### Home Manager profiles
- `modules/home/minimal.nix`: CLI, shell, Ghostty, VSCode, Nix tooling, git, direnv, Teleport
- `modules/home/development.nix`: `minimal` plus full dev modules, editors, and language tooling
- `modules/home/default.nix`: `development` plus misc desktop apps

### NixOS layers
- `modules/nixos/minimal.nix`: shared Nix settings plus base Linux system config
- `modules/nixos/graphical.nix`: `minimal` plus fonts, desktop, audio, networking, i18n, and power
- `modules/nixos/default.nix`: `graphical` plus NVIDIA

### Darwin layers
- `modules/darwin/default.nix`: shared Nix settings, fonts, Darwin base, Homebrew, and system defaults

## Conventions

- One concern per file where practical: tools, languages, and app groups are split into dedicated `.nix` files
- `default.nix` files are usually composition entrypoints that mostly import other modules
- Personal data lives in `personal.nix`
- Newer packages should use `pkgs.unstable.*` instead of replacing the stable package set
- Indentation is 2 spaces
- Theme choices are centered on Catppuccin Mocha across terminals, editors, and CLI tools

## Build and Apply Commands

```bash
# Activate the current machine
nix run .#activate

# Activate a specific target
nix run .#activate blender
nix run .#activate mixer
nix run .#activate juicer
nix run .#activate citrus@

# Update inputs, then activate
nix run .#update && nix run .#activate

# Check evaluation and configured flake checks
nix flake check
```

Direct rebuild commands still work when needed:

```bash
# NixOS
sudo nixos-rebuild switch --flake .#blender

# macOS
darwin-rebuild switch --flake .#mixer
darwin-rebuild switch --flake .#juicer
```

## Development Workflow

1. Edit the relevant host, profile, or module file
2. Run `nix flake check`
3. Apply with `nix run .#activate` or a target-specific activation
4. Verify the expected system or Home Manager behavior

Entering the dev shell installs the configured pre-commit hooks automatically.

## Notable Details

- `modules/flake/git-hooks.nix` enables `nixfmt-rfc-style` as the pre-commit formatter
- `modules/home/editors/neovim.nix` uses Neovim's native LSP setup rather than external plugin managers for LSP wiring
- `modules/darwin/system-defaults.nix` is opinionated and changes real macOS defaults, keybindings, and system behavior
- `modules/nixos/system/networking.nix` and `modules/nixos/system/nvidia.nix` have machine-specific impact, so treat changes there carefully

## Caveats

- `modules/shared/default.nix` appears stale and currently references `./shell.nix`, which does not exist
- Documentation should treat `mixer` and `juicer` as the active Darwin hosts; older references to `squeezer` are outdated
