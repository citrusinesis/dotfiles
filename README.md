# dotfiles

Personal NixOS and macOS configuration using [flake-parts](https://flake.parts/),
[flake-aspects](https://github.com/denful/flake-aspects), and system-integrated
Home Manager. Build and switch systems with [nh](https://github.com/nix-community/nh).

## Setup

```bash
git clone git@github.com:citrusinesis/dotfiles.git "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
cd "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
./scripts/bootstrap.sh
# Choose the current machine from the table below.
nix run .#nh -- darwin build . -H juicer
nix run .#nh -- darwin switch . -H juicer
```

Bootstrap reuses an existing Nix installation and installs Lix only on a clean
machine. On macOS it also installs Homebrew if needed. It does not apply the
configuration. The `.#nh` package uses this repository's locked nixpkgs version.

| Host | Platform | User | Profiles |
| --- | --- | --- | --- |
| `juicer` | aarch64-darwin | citrus | developer + workstation |
| `mixer` | aarch64-darwin | citrus | developer + workstation |
| `blender` | x86_64-linux / WSL | citrus | developer |
| `ws-jh-song` | x86_64-linux / Proxmox LXC | jh-song | developer |

For either Linux host, use `nix run .#nh -- os build . -H <host>` and then
`nix run .#nh -- os switch . -H <host>` on that host. Run nh as your normal user;
it obtains privileges for the steps that need them.

## Build, switch, and update

After activation, Home Manager's `programs.nh.flake` sets `NH_FLAKE` to
`${config.xdg.configHome}/dotfiles`. By default this is `~/.config/dotfiles`.
For a different XDG location, configure Home Manager's `xdg.configHome` as well
as cloning there. Open a new login shell after the first activation.

```bash
nh darwin build -H juicer
nh darwin switch -H juicer
nh os build -H blender
nh os switch -H blender
nh clean all --keep 5 --keep-since 3d
```

When working from another checkout or worktree, pass its path explicitly so nh
does not build the checkout selected by `NH_FLAKE`:

```bash
nh darwin build . -H juicer
```

Maintenance operations are explicit. From the repository:

```bash
nix run .#update-pinned-packages  # Local package pins, including Apple Container
nix flake update                # Flake input revisions
nix flake check --all-systems --no-build
nix flake check                 # Build checks for the current platform
nh darwin build . -H juicer      # Use `nh os build` on NixOS
nh darwin switch . -H juicer     # Apply after reviewing the changes
```

`nh ... switch --update` updates flake inputs before switching, but does not run
the local package updater, flake checks, or Homebrew updates. There are no legacy
activation/update wrappers or standalone Home Manager outputs. Home Manager is
applied as part of the system. The generic `nb`, `nd`, `nr`, and `ns` aliases remain.

Automatic system GC retains the existing 14-day policy. No additional nh cleanup
timer is enabled; `nh clean` is available for manual maintenance.

## Aspect structure

The private scope has three collections:

```nix
dotfiles.aspects = {
  features.provides = { /* reusable features */ };
  profiles.provides = { /* feature combinations */ };
  hosts.provides = { /* machine composition and overrides */ };
};
```

`modules/features` is grouped by platform, terminal, development, and desktop
concerns. Directory grouping does not determine logical names: Zed lives under
`features/development/zed`, but is named `features.provides.zed`.

Every directory entry point imports its children explicitly. To add a feature,
register its directory in `modules/features/default.nix` and give it class modules:

```nix
{
  dotfiles.aspects.features.provides.example = {
    darwin = ./darwin.nix;
    homeManager = ./home.nix;
  };
}
```

Put actual options in those files, reference feature dependencies with `includes`,
and use ordinary `imports` for implementation files inside a feature. Importing
the same file through multiple feature dependencies applies it once. Avoid
inline option definitions in reusable aspects and never create cyclic includes.

`provides` only groups names; including its parent does not select its children.
Profiles and hosts select individual providers explicitly:

```nix
{ config, ... }:
let
  features = config.dotfiles.aspects.features.provides;
in
{
  dotfiles.aspects.profiles.provides.example.includes = [ features.zed ];
}
```

The `developer` profile supplies terminal development tools. `workstation`
supplies desktop applications and integration. They are independent; development
desktops select both. Every host also selects `core` and its platform feature.

Kitty, VS Code, and Podman are available features but are not selected by the
current hosts. Apple Container is selected by both Darwin hosts. Linux graphical,
NVIDIA, NVIDIA LXC, always-on, and Tailscale exit-node features remain available
for explicit selection. Linux desktop environment selection is separate from the
workstation profile.

Apple Container and Podman retain their module-level enable options. To run
Apple Container's owned-state cleanup, keep the feature included and set
`dotfiles.home.appleContainer.enable = false` for an activation before removing
the feature. User-owned data is preserved by its ownership checks.

`lib/mk-darwin.nix` and `lib/mk-nixos.nix` resolve each host with
`aspect.resolve { class = "darwin"; }` / `"nixos"` and `"homeManager"`, then use
the official system constructors and Home Manager integration. Composition-only
aspects need no empty class declarations. These builders do not choose features.

Register a new host's aspect in `modules/hosts/default.nix` and its system output
in `modules/flake/configurations.nix`. System `users.users` defines the account
and home directory; Home Manager inherits them.

Public outputs are the four system configurations, `overlays.default`, the pinned
`packages.<system>.nh`, local `legacyPackages`, `apps.<system>.update-pinned-packages`,
checks, formatter, and development shells. Aspects stay private. The Apple
Container updater retains `legacyPackages.<system>.apple-container`.

## Darwin application ownership

Desktop apps declared by this repository are installed through Homebrew casks.
App Store apps use `masApps`. Nix continues to manage command-line tools, libraries,
fonts, terminfo, editor settings and extensions. Native `pinentry_mac` is the
explicit authentication-helper exception, preserving GUI GPG passphrase entry.
Linux GUI packages remain Nix-managed.

The common casks are `helium-browser`, `spotify`, `slack`, `raycast`, `claude`,
`chatgpt`, `linear`, `tailscale-app`, `logi-options+`, `element`, `ghostty`,
`monitorcontrol`, `obsidian`, `zed`, and `winbox`.

| Host | Additional casks |
| --- | --- |
| juicer | notion, cloudflare-warp, lm-studio, utm |
| mixer | mongodb-compass |

KakaoTalk (`869223134`) and RunCat Neo (`6757801838`) use `masApps`. The `mas`
formula is common, and mixer also installs `mole`.

Before enabling an optional cask, check it with `brew info --cask <name>`.
The installed Homebrew may need an explicit `brew update` to understand a newer
cask definition. During migration, the optional Kitty cask reported an unsupported
`command_wrapper` method with Homebrew 6.0.10; it remains unselected. This is a
Homebrew runtime compatibility issue, separate from its Home Manager settings check.

GUI features own both their cask and Home Manager settings. On Darwin, Zed,
Kitty, and VS Code use `package = null` for settings-only management; on Linux
they use Nix packages. Kitty and VS Code casks appear only when their features
are selected. Home Manager app linking and copying are explicitly disabled.

The Ghostty cask does not link its executable into Homebrew's `bin`, so its
application executable directory is added to the session PATH. The Zed cask
provides the `zed` command. CLI tools supplied by Nix keep priority over Homebrew.

Activation installs declared applications with `autoUpdate = false` and
`upgrade = false`. It retains `cleanup = "zap"`: undeclared Homebrew packages
are removed, including associated data covered by a removed cask's zap stanza.
Declare wanted packages before switching. This policy does not inventory or
remove arbitrary manually installed applications.

Homebrew versions are not pinned by `flake.lock`. App auto-updaters may still run,
and switching to an older Nix generation does not restore earlier cask versions.
Homebrew updates are separate:

```bash
brew update
brew upgrade --cask --greedy
```

App Store installation requires an authenticated App Store session and may
require prior acquisition of the app. Use `mas upgrade` to update those apps.
The pinned nix-darwin module does not guarantee automatic removal of applications
deleted from `masApps`; check and remove them separately when changing that list.

### First application after migration

Build the configuration and review its package diff before switching. Check
existing casks with `brew list --cask` and App Store apps with `mas list`; the
existing zap policy still applies. A manually installed app at a cask destination
can cause an installation conflict: inspect its ownership before resolving it.
Do not blanket-delete applications or their settings.

After switching, open a new login shell and verify:

- Zed and Ghostty launch from their Homebrew-managed app bundles; `command -v zed`
  and `command -v ghostty` find their cask-supplied executables.
- Zed settings/extensions and Ghostty fonts/theme are present.
- The former Home Manager application link is removed by normal activation,
  without enabling Home Manager application copying.
- A GPG signing operation can still show the native passphrase dialog.
- Apple Container still starts and reads its managed configuration.

Nix evaluation/builds do not install casks, authenticate the App Store, or test
GUI launch behavior. These checks therefore belong to the first real activation.

## Validation

```bash
nix flake check --all-systems --no-build
nix flake check
nh darwin build . -H juicer
nh darwin build . -H mixer
```

Run `nh os build . -H blender` and `nh os build . -H ws-jh-song` on an x86_64-linux
builder. All-system evaluation works from either platform; actual foreign-system
builds require a configured builder. Report evaluation and build results separately.

Checks cover embedded Home Manager activation derivations, aspect resolution and
file deduplication, host identity and enabled features, application ownership,
the XDG-based nh path, and optional Kitty/VS Code settings-only configurations.
Darwin build checks also inspect the applications exposed by the Nix profiles.
Existing formatting, Nix linting, shell linting, and secret checks remain enabled.
