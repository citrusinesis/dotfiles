# dotfiles

Personal NixOS and macOS configuration, built and activated with [nh](https://github.com/nix-community/nh).

## Setup

```bash
git clone git@github.com:citrusinesis/dotfiles.git "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
cd "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
./scripts/bootstrap.sh
nix run --inputs-from . nixpkgs#nh -- darwin switch . -H <host>
```

On NixOS, replace `darwin` with `os`.

## Hosts

| Host | Platform | Home |
| --- | --- | --- |
| `blender` | x86_64-linux / bare metal | `citrus@blender` |
| `juicer` | aarch64-darwin | `citrus@juicer` |
| `mixer` | aarch64-darwin | `citrus@mixer` |
| `ws-jh-song` | x86_64-linux / Proxmox LXC | `jh-song@ws-jh-song` |

## Usage

The `update` workflow runs every day: it updates `flake.lock`, then runs the `updateScript` of every package in `packages`, and pushes each to main only after every system evaluates.
A failed step opens an `auto-update` issue, which closes itself on the next successful run.

```bash
git pull && nh darwin switch
git pull && nh os switch
git pull && nh home switch
```
