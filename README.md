# Nix Configuration

Personal Nix flake for managing NixOS and macOS systems with Home Manager, powered by [nixos-unified](https://github.com/srid/nixos-unified).

## Systems

| Host | OS | Arch | Home profile | Description |
|------|----|------|--------------|-------------|
| **blender** | NixOS | x86_64 | `default` | Desktop with KDE Plasma 6 and NVIDIA GPU |
| **mixer** | macOS | aarch64 | `default` | Main macOS setup with the smaller app set |
| **juicer** | macOS | aarch64 | `development` | macOS setup with the broader app set and dev-focused Home Manager profile |

## Quick Start

```bash
# Activate the current machine (auto-detects hostname)
nix run .#activate

# Update flake inputs, then activate
nix run .#update && nix run .#activate

# Validate evaluation and checks
nix flake check
```

## New Machine Setup

```bash
# 1. Install Nix
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# 2. Enable flakes
mkdir -p ~/.config/nix
printf 'experimental-features = nix-command flakes\n' >> ~/.config/nix/nix.conf

# 3. Clone the repo
git clone <repo> ~/.config/dotfiles
cd ~/.config/dotfiles

# 4. Activate a target
nix run .#activate          # Match current hostname
nix run .#activate blender  # NixOS desktop
nix run .#activate mixer    # macOS default profile
nix run .#activate juicer   # macOS development profile
nix run .#activate citrus@  # Home Manager only target
```

## Structure

```text
.
|- flake.nix                         # Flake entrypoint
|- personal.nix                      # User identity and shared personal data
|- configurations/
|  |- nixos/blender/                 # nixosConfigurations.blender
|  |- darwin/mixer/                  # darwinConfigurations.mixer
|  |- darwin/juicer/                 # darwinConfigurations.juicer
|  `- home/
|     |- minimal/                    # homeConfigurations.* using homeModules.minimal
|     |- development/                # homeConfigurations.* using homeModules.development
|     `- default/                    # homeConfigurations.* using homeModules.default
`- modules/
   |- flake/                         # Flake modules: auto-wiring, overlays, hooks
   |- shared/                        # Cross-platform modules: Nix, fonts
   |- nixos/                         # NixOS module composition
   |- darwin/                        # nix-darwin module composition
   `- home/                          # Home Manager modules by category/profile
```

## Profiles

- `minimal`: CLI tools, shell, Ghostty, VSCode, Nix tooling, git, direnv, Teleport
- `development`: `minimal` plus full dev tooling, editors, and language modules
- `default`: `development` plus misc desktop apps from `modules/home/misc/apps.nix`

## Module Layout

- `modules/home/cli/`: shell-adjacent CLI tools such as `bat`, `eza`, `fd`, `ripgrep`, `ssh`
- `modules/home/dev/`: git, direnv, podman, kubernetes, teleport
- `modules/home/editors/`: Neovim, VSCode, Zed
- `modules/home/languages/`: language runtimes, LSP servers, formatters, and linters
- `modules/nixos/`: layered as `minimal -> graphical -> default`
- `modules/darwin/`: shared Darwin base, Homebrew integration, and system defaults

## Languages

Each language module installs the runtime when needed, plus the language server and common tooling.

| Language | Runtime | LSP | Tools |
|----------|---------|-----|-------|
| Go | `go` | `gopls` | `gofumpt`, `golangci-lint` |
| Rust | `rustc`, `cargo` | `rust-analyzer` | `clippy`, `rustfmt` |
| TypeScript | `nodejs` | `typescript-language-server` | `prettier` |
| Python | `python3` | `pyright` | `ruff` |
| Nix | - | `nixd` | `nixfmt-rfc-style` |
| YAML | - | `yaml-language-server` | - |
| JSON | - | `vscode-langservers-extracted` | - |

## Workflow

- Make changes in the relevant module or host file
- Run `nix flake check` for evaluation and repo checks
- Apply with `nix run .#activate` or target a specific host/profile
- Use the dev shell to install the configured pre-commit hooks automatically

## Notes

- `flake.nix` delegates most output wiring to `nixos-unified`; `modules/flake/toplevel.nix` enables auto-wiring
- `nixpkgs` tracks `25.11`, with newer packages exposed through `pkgs.unstable.*`
- Formatting is enforced through `git-hooks.nix` with `nixfmt-rfc-style`
