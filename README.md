# dotfiles

## Setup

Install [Lix](https://lix.systems/install/):

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

On macOS, install [Homebrew](https://brew.sh/):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Clone and activate a host from `hosts/` (`os` instead of `darwin` on NixOS):

```bash
git clone git@github.com:citrusinesis/dotfiles.git "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
cd "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
nix run --inputs-from . nixpkgs#nh -- os switch . -H <host>
```

## Usage

```bash
git pull && nh darwin switch
git pull && nh os switch
```
