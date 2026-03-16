# Nix Configuration

Personal Nix flake for managing NixOS and macOS systems with Home Manager, powered by [nixos-unified](https://github.com/srid/nixos-unified).

## Systems

| Host | OS | Arch | Home profile | Description |
|------|----|------|--------------|-------------|
| **blender** | NixOS | x86_64 | `default` | Desktop with KDE Plasma 6 and NVIDIA GPU |
| **mixer** | macOS | aarch64 | `default` | Work Mac mini with a smaller app set |
| **juicer** | macOS | aarch64 | `development` | Personal laptop with the full dev toolchain |

## New Machine Setup

```bash
# 1. Clone the repo
git clone <repo> ~/.config/dotfiles
cd ~/.config/dotfiles

# 2. Run setup (installs Lix + Homebrew on macOS)
./setup.sh

# 3. Activate
nix run .#activate
```

## Usage

```bash
nix run .#activate          # Match current hostname
nix run .#activate blender  # NixOS desktop
nix run .#activate mixer    # macOS default profile
nix run .#activate juicer   # macOS development profile

nix run .#update && nix run .#activate  # Update inputs, then activate
nix flake check                         # Validate evaluation and checks
```

## Structure

```text
.
|- flake.nix                         # Flake entrypoint
|- personal.nix                      # User identity and shared personal data
|- setup.sh                          # Bootstrap: Lix + Homebrew
|- configurations/
|  |- nixos/blender/                 # nixosConfigurations.blender
|  |- darwin/mixer/                  # darwinConfigurations.mixer
|  |- darwin/juicer/                 # darwinConfigurations.juicer
|  `- home/
|     |- minimal/                    # homeConfigurations.* using homeModules.minimal
|     |- development/                # homeConfigurations.* using homeModules.development
|     `- default/                    # homeConfigurations.* using homeModules.default
`- modules/
   |- flake/                         # Flake-level: auto-wiring, overlays, git-hooks
   |- shared/                        # Cross-platform: Nix settings, fonts, timezone, zsh
   |- nixos/                         # NixOS: minimal -> graphical -> default (+ system/)
   |- darwin/                        # nix-darwin: base, homebrew, system/{defaults,dock,finder,input,security}
   `- home/                          # Home Manager: cli, dev, editors, languages, misc, shell, terminals
```

## Profiles

| Profile | Contents |
|---------|----------|
| `minimal` | CLI tools, shell, Ghostty, VSCode, Nix tooling, git, direnv, Teleport |
| `development` | `minimal` + full dev tooling, editors (Neovim, Zed), all language modules |
| `default` | `development` + misc desktop apps |

## Languages

| Language | Runtime | LSP | Tools |
|----------|---------|-----|-------|
| Go | `go` | `gopls` | `golangci-lint`, `gotools` |
| Rust | `rustc`, `cargo` | `rust-analyzer` | `clippy`, `rustfmt`, `cargo-deny`, `cargo-outdated` |
| TypeScript | `nodejs`, `bun` | `typescript-language-server` | `prettier`, `eslint`, `pnpm` |
| Python | `python3` | `pyright` | `ruff`, `black`, `uv` |
| Nix | — | `nixd` | `nixfmt-rfc-style`, `statix`, `deadnix` |
| YAML | — | `yaml-language-server` | `yamllint`, `yq-go` |
| JSON | — | `vscode-langservers-extracted` | `jq`, `jless` |

## Notes

- `flake.nix` delegates output wiring to `nixos-unified`; `modules/flake/toplevel.nix` enables auto-wiring
- `nixpkgs` tracks `25.11`, with newer packages exposed through `pkgs.unstable.*`
- Formatting is enforced through `git-hooks.nix` with `nixfmt-rfc-style`
- Theme convention is Catppuccin Mocha across terminals, editors, and CLI tools
