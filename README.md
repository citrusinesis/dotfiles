# dotfiles

Personal NixOS and macOS configuration using [flake-parts](https://flake.parts/)
and [flake-aspects](https://github.com/denful/flake-aspects).
User, Host and Account declarations compose the system and Home Manager outputs.
Build and activate them with [nh](https://github.com/nix-community/nh).

## Setup and daily use

```bash
git clone git@github.com:citrusinesis/dotfiles.git "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
cd "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
./scripts/bootstrap.sh
nix run .#nh -- darwin build .
nix run .#nh -- darwin switch .
```

Bootstrap reuses an existing Nix installation, installs Lix on a clean machine,
and installs Homebrew on macOS if necessary. It does not activate configuration.
On NixOS, replace `darwin` with `os`. Run nh as your normal user; system activation
obtains privileges when needed. Open a new login shell after the first switch.

| Host | Platform | Primary Account |
| --- | --- | --- |
| `juicer` | aarch64-darwin | `citrus@juicer` |
| `mixer` | aarch64-darwin | `citrus@mixer` |
| `blender` | x86_64-linux / WSL | `citrus@blender` |
| `ws-jh-song` | x86_64-linux / Proxmox LXC | `jh-song@ws-jh-song` |

```bash
nh darwin build                 # Current Mac
nh darwin switch
nh os build                     # Current NixOS host
nh os switch
nh home build                   # Current user@host on either platform
nh home switch
```

`NH_FLAKE` is the checkout path `${config.xdg.configHome}/dotfiles`, normally
`~/.config/dotfiles`. Configure `xdg.configHome` if using another XDG location.
An explicit path selects another checkout or worktree:

```bash
nh darwin build . -H mixer
nh home build . -c 'citrus@mixer'
```

nh detects `LocalHostName` on macOS and `hostname` on Linux. A Host ID must match
that name. Managed Darwin sets both `hostName` and `localHostName`. Use `-H` for
the first switch if the machine has a different name. `nh home` selects
`homeConfigurations."user@host"`, including `jh-song@ws-jh-song`, without username
translation. No custom host detection or activation wrapper is involved.

Every managed Account has both a system-integrated Home and a standalone Home.
`nh home switch` applies Home settings; `nh darwin switch` / `nh os switch` also
apply OS users, services and system applications. Both compose the same Home
modules and use the same Host packages. A fresh login shell prioritizes the
package profile belonging to that activation form. A later system switch
reapplies the Home in that checkout; it does not delete standalone generations.

Activation backs up conflicting Home files with unique timestamped names.
Explicit Home Manager backup commands and `nh home ... -b <extension>` take
precedence. System GC retains the 14-day policy; nh has no additional cleanup timer.

```bash
nix flake update
nix flake check --all-systems --no-build
nix flake check
nh clean all --keep 5 --keep-since 3d
```

## User, Host and Account

- **User**: the login name, development tools and personal preferences shared
  across machines. `citrus` and `jh-song` are separate Users with shared Git data.
- **Host**: platform, hardware, networking and services. A managed Host declares
  a `primaryAccount` for services that need one owner.
- **Account**: a `user@host` pair, Home state version and directory, desktop
  feature selection, and native user permissions such as UID/GID, groups and sudo.

Each entity is declared once in `dotfiles.inventory`, with its aspect inline.
Only reusable features are registered in the private
`dotfiles.aspects.features.provides` collection. There is no profile layer.

```nix
{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in {
  dotfiles.inventory = {
    users.alice.aspect.includes = [ features.cli features.shell ];
    hosts.laptop = {
      system = "aarch64-darwin";
      backend = "darwin";
      primaryAccount = "alice@laptop";
      aspect = {
        includes = [ features.core features.darwin ];
        darwin.system.stateVersion = 5;
      };
    };
    accounts."alice@laptop" = {
      home.stateVersion = "25.11";
      aspect.includes = [ features.fonts features.ghostty ];
    };
  };
}
```

Import new entries explicitly from their parent `default.nix`. Account directory
names match their keys, for example `modules/accounts/citrus@juicer`.
Account modules are ordinary Nix modules; an account-specific file can name its
user directly. No context factory or additional module key is needed.

Each Home composes **Host Home + User Home + Account Home**. Native systems compose
Host modules plus all connected User and Account native modules. Shared feature
files are deduplicated by Nix. Normal option merging applies, with identity derived
from inventory. Home directories default to `/Users/<user>` or `/home/<user>`;
set `home.directory` for an existing nonstandard location. `home.stateVersion`
is required. System state versions belong in Host modules.

`lib/mk-configurations.nix` builds the standard outputs with the official
constructors; `lib/system-adapter.nix` connects OS users and integrated Home.
`modules/home.nix` contains common Home activation policy. Package configuration
and overlays have one shared import; application bundles use `/Applications`.

For an existing unmanaged OS, use `backend = "unmanaged"`, omit `primaryAccount`,
and register its existing user and hostname. It provides standalone Home only.
See [examples](examples/unmanaged.nix). Unmanaged Linux enables generic Linux and
fontconfig support. Unmanaged macOS manages fonts, settings and terminfo, adds
Homebrew to PATH, and expects GUI apps to be installed separately.

## Applications and services

Darwin GUI applications come from Homebrew casks and `masApps`; Nix manages CLI
tools, fonts and editor settings. Native `pinentry-mac` is the authentication-helper
exception. Home Manager app linking/copying is disabled. Kitty, VS Code and Podman
remain optional features. Select a feature to enable it; NVIDIA LXC additionally
requires a user-space driver matching the physical host's kernel driver.

Homebrew activation keeps `autoUpdate = false`, `upgrade = false` and
`cleanup = "zap"`. Declare wanted packages before switching: undeclared packages
and data covered by cask zap rules can be removed. Homebrew versions are not pinned
by `flake.lock`; updates use `brew update` / `brew upgrade --cask --greedy`.
App Store installations require an authenticated session; use `mas upgrade` for
updates and remove formerly declared App Store applications separately.

Apple Container is a Host service owned by the primary Account. The pinned
upstream module manages its signed CLI, kernel and launchd jobs. Defaults are
8 CPUs, 4 GiB RAM and the `.test` DNS domain. Package/kernel updates restart the
runtime, and activation refreshes its Background agent without requiring login.
Declare workloads through `services.containerization.containers` in a Host module.
Activation prunes stopped containers and removes undeclared workloads.

To remove Apple Container, keep the feature selected and activate
`services.containerization.enable = false` once before removing the feature.
Set `preserveImagesOnDisable` / `preserveVolumesOnDisable` first if needed.
See the [service validation record](docs/apple-container-migration-validation.md)
for legacy cleanup and the pinned upstream's GUI-session autostart limitation.

Keep Nix's background items enabled. Scheduled/startup jobs may be idle after
success. Stable launchers retain `wait4path /nix/store`; juicer also mounts its
encrypted Nix volume at boot. GPG starts its Darwin agent on demand, avoiding a
second supervised agent. KeyRemapping activation retires the legacy nix-darwin
GUI registration before Home Manager loads its replacement, including recovery
from a partially failed switch.

PF restricts selected SSH/Screen Sharing services to Tailscale. Its anchor,
Tailscale address ranges and SSH port 22 are fixed. Locks, deny-only boot rules,
rule validation and cleanup when disabled remain active.

## Validation

Checks cover real native and Home outputs, two-Account isolation, shared-module
deduplication, integrated/standalone parity, nh naming and XDG paths, unmanaged
platforms, GUI ownership and the KeyRemapping activation regression.
Formatting, Nix linting, shell linting and secret checks remain enabled.

Build Darwin configurations locally with `nh darwin build . -H <host>`; build
Linux configurations on an x86_64-linux builder with `nh os build . -H <host>`.
Evaluation/builds do not activate services, install casks or test GUI applications.

Historical records: [Account migration](docs/account-migration-validation.md),
[aspect migration](docs/aspect-migration-validation.md), and
[structure simplification](docs/structure-simplification.md).
