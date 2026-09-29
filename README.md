# dotfiles

Personal NixOS and macOS configuration using [flake-parts](https://flake.parts/),
ordinary NixOS / nix-darwin / Home Manager modules, and one host table.
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

| Host | Platform | Home |
| --- | --- | --- |
| `juicer` | aarch64-darwin | `citrus@juicer` |
| `mixer` | aarch64-darwin | `citrus@mixer` |
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

Every host's user has both a system-integrated Home and a standalone Home.
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

## Layout

```
flake/hosts.nix     host table: system, user and Home state version per host
lib/modules.nix     exposes modules/ as `modules.<class>.<name>`
lib/mk-host.nix     builds hosts/<name> into a system, integrated Home and standalone Home
hosts/<name>/       default.nix (system) and home.nix (its user's Home)
modules/system/     shared by nix-darwin and NixOS (core Nix settings, fonts)
modules/darwin/     every Mac (default.nix) plus optional modules
modules/nixos/      every NixOS host (default.nix) plus optional modules
modules/home/       every Home (default.nix) plus optional applications
```

A module is selected by importing it; there are no `enable` switches for
features. Shared files imported more than once are deduplicated by Nix.

Hosts refer to modules as `modules.<class>.<name>`, generated from the
directory tree by `lib/modules.nix`; `modules.<class>.default` is the class's
common module. New files appear there without registration.

```nix
# hosts/laptop/default.nix
{ modules, ... }:
{
  imports = [
    modules.darwin.default
    modules.system.fonts
  ];
  time.timeZone = "Asia/Seoul";
}

# hosts/laptop/home.nix
{ modules, ... }:
{
  imports = [
    modules.home.default
    modules.home.ghostty
  ];
}
```

Register the host in `flake/hosts.nix`. `mk-host.nix` fixes the hostname, the
user's home directory (`/Users/<user>` or `/home/<user>`), `system.primaryUser`
on macOS and `dotfiles.primaryUser` for modules that need the owner. Package
configuration and overlays have one shared import there; `modules/home/activation.nix`
contains common Home activation policy. System state versions belong in host modules.

Home application modules declare their Homebrew casks with `dotfiles.casks`;
nix-darwin installs the casks of every integrated Home. Casks without Home
settings (`modules/darwin/applications.nix`, host-specific apps) stay in system modules.

## Applications and services

Darwin GUI applications come from Homebrew casks and `masApps`; Nix manages CLI
tools, fonts and editor settings. Native `pinentry-mac` is the authentication-helper
exception. Home Manager app linking/copying is disabled. Kitty, VS Code and Podman
remain optional modules. Import a module to enable it; NVIDIA LXC additionally
requires a user-space driver matching the physical host's kernel driver.

Homebrew activation keeps `autoUpdate = false`, `upgrade = false` and
`cleanup = "zap"`. Declare wanted packages before switching: undeclared packages
and data covered by cask zap rules can be removed. Homebrew versions are not pinned
by `flake.lock`; updates use `brew update` / `brew upgrade --cask --greedy`.
App Store installations require an authenticated session; use `mas upgrade` for
updates and remove formerly declared App Store applications separately.

Apple Container is a host service owned by the host's user. The pinned
upstream module manages its signed CLI, kernel and launchd jobs. Defaults are
8 CPUs, 4 GiB RAM and the `.test` DNS domain. Package/kernel updates restart the
runtime, and activation refreshes its Background agent without requiring login.
Declare workloads through `services.containerization.containers` in a host module.
Activation prunes stopped containers and removes undeclared workloads.

`nh darwin build` checks the locked configuration without activating it.
Use `nh darwin switch . -H <host> -U nix-apple-container` to update the service
input and activate it. A plain switch uses the existing lock. The service's
package version follows `halfwhey/nix-apple-container`, so it can lag Apple's
releases even when that input is fully updated.

To remove Apple Container, keep the module imported and activate
`services.containerization.enable = false` once before removing the import.
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

Checks cover real native and Home outputs, host identity, integrated/standalone
parity, Darwin preference isolation, optional editor casks, nh naming and XDG paths,
GUI ownership and the KeyRemapping activation regression.
Formatting, Nix linting, shell linting and secret checks remain enabled.

Build Darwin configurations locally with `nh darwin build . -H <host>`; build
Linux configurations on an x86_64-linux builder with `nh os build . -H <host>`.
Evaluation/builds do not activate services, install casks or test GUI applications.

Historical records: [Account migration](docs/account-migration-validation.md),
[aspect migration](docs/aspect-migration-validation.md),
[structure simplification](docs/structure-simplification.md) and
[aspect removal](docs/aspect-removal.md).
