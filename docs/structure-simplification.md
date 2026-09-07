# Structure simplification — 2026-09-07

The Account migration initially registered each entity twice and introduced
context factories, per-host package metadata and four Home modes. This revision
keeps User / Host / Account ownership while removing that machinery.

## Changes

- One inventory declaration per entity, with its aspect inline; canonical
  `user@host` Account directory names. Private feature aspects remain reusable.
- Ordinary Account modules instead of factories; only the consumed unmanaged
  boolean is supplied to Home modules.
- One native construction path. Shared Home activation policy lives in an ordinary
  module; hostnames and Home identity are fixed from inventory.
- Required state versions and managed primary Accounts are typed at declaration.
  Reference/backend checks fail immediately, without collecting/filtering errors.
- Common package import, overlays and `/Applications` path; no per-host knobs.
- Podman and NVIDIA LXC selection directly enables their configuration. The NVIDIA
  driver package remains required data.
- NetworkManager and power management are no longer enabled by common NixOS base
  only to be force-disabled by every real Host. Hosts explicitly disable them.
  Removing the common CPU governor also removes WSL's unused `cpupower`,
  cpufreq unit and governor kernel-module declaration (the unit was already
  conditioned not to run under virtualization).
- PF anchor, Tailscale ranges and SSH port are constants. Rule generation and
  lifecycle scripts remain unchanged, including old-anchor cleanup.
- Nixvim uses `require("snacks")` directly. The plugin is enabled with explorer;
  missing dependencies surface errors. Normal window/tab race handling remains.
- Apple Container only skips unloading when its job is absent. Unloading a
  registered job must succeed before bootstrap.
- cargo-watch uses its own `overrideAttrs` for LLVM linking on Darwin, replacing
  interception of `buildRustPackage`. The locked nixpkgs builder supports this
  through `lib.extendMkDerivation`.
- Tests focus on composition and operational contracts; README describes current
  usage instead of repeating lists of packages and migration history.

## Deliberate support changes

`home.mode` is removed: managed Accounts always have both integrated and standalone
Home; unmanaged Hosts always have standalone Home. All four existing Accounts
already used both. Arbitrary per-host nixpkgs policy/application directories and
PF address/port customization are also removed; no registered Host used them.

Unmanaged support, unique collision backups and explicit backup precedence,
optional editor/Podman features, and mutable VS Code settings remain unchanged.

## Retained compatibility and recovery

The pinned nix-apple-container module builds its runtime plist internally, with
no option for its script path. Its module-local script builder adjustment remains
to preserve meaningful Login Items executable names; replacing it would require
copying upstream activation/plist implementation.

The pinned Nixvim uses `stdenv.hostPlatform` in its active modules. The obsolete
`stdenv.isDarwin`/`isLinux` overlay aliases are removed.

KeyRemapping's registered-path migration, encrypted-volume startup, PF locking,
deny-only startup and disable cleanup, GPG agent ownership and bootstrap download
validation remain. Remove the KeyRemapping migration after all affected machines
have transitioned, not merely after the legacy plist disappears.

## Validation

- `nix flake check --all-systems --no-build`: passed on Darwin and Linux outputs.
- `nix flake check` on Darwin: passed, including formatting, deadnix, statix,
  shellcheck, secret detection, GUI ownership and KeyRemapping regression checks.
- Both Darwin systems and both Darwin standalone Homes: built locally.
- Both NixOS systems and both Linux standalone Homes: built on the native
  x86_64-linux `capitol-workspace` builder. Linux Account composition and policy
  checks also built successfully. No remote checkout or activation was changed.
- Four-host snapshots match for identities, packages, Git, Home environment,
  Darwin preferences/app selection and Linux permissions/services, after accounting
  for removed PF option metadata and WSL's `cpupower` package.
- PF generated configuration, anchor text and launchd service configurations
  match the pre-simplification generation.
- cargo-watch retains the same LLVM linker flags and input; its narrower
  override built successfully. Derivation paths can change after removing the
  stdenv overlay aliases.
- Optional Podman selection and its Home activation derivation evaluated.
- Headless Neovim smoke test: Snacks/explorer API loading and tab creation/closing
  passed with isolated XDG directories.
- Mock execution of the actual Apple Container post-activation fragment: missing
  domain/job, normal registration, unload error, enable error and bootstrap error
  all behaved as expected. Errors stop activation rather than falling through.

These are evaluation, build and isolated runtime checks. Full system activation
and GUI application checks were not performed during this simplification.
