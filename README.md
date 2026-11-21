# dotfiles

Personal NixOS and macOS configuration, built and activated with [nh](https://github.com/nix-community/nh).

## Setup

On a fresh machine without Nix, install [Lix](https://lix.systems/install/), then restart your shell:

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

On macOS, install [Homebrew](https://brew.sh/) if needed and follow its printed shell setup instructions:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Clone and activate the host configuration:

```bash
git clone git@github.com:citrusinesis/dotfiles.git "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
cd "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
nix run --inputs-from . nixpkgs#nh -- darwin switch . -H <host>
```

On NixOS, use its existing Nix installation and replace `darwin` with `os`.

## Hosts

| Host | Platform |
| --- | --- |
| `blender` | x86_64-linux / bare metal |
| `juicer` | aarch64-darwin |
| `mixer` | aarch64-darwin |
| `ws-jh-song` | x86_64-linux / Proxmox LXC |

## Usage

The `update` workflow runs every day: it updates `flake.lock`, then runs the `updateScript` of every package in `packages`, and pushes each to main only after every system evaluates.
A failed step opens an `auto-update` issue, which closes itself on the next successful run.

```bash
git pull && nh darwin switch
git pull && nh os switch
```
