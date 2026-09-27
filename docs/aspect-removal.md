# Aspect removal — 2026-09-26

flake-aspects and the User / Host / Account inventory are replaced by ordinary
modules selected through `imports` and one host table. flake-parts remains the
only flake framework.

## Why

Aspects were used for two things: pairing a feature's system and Home modules
(mostly a single Homebrew cask line) and `includes = [ theme ]`, which plain
`imports` already deduplicates. Supporting them required an inventory schema,
reference validation, a configuration builder, a system adapter and dedicated
tests. With four hosts of one user each, the User / Account split added no
selection the host could not express directly.

## Changes

- `flake/hosts.nix` lists each host's system, user and Home state version.
  `lib/mk-host.nix` builds `hosts/<name>/default.nix` into the native system and
  `hosts/<name>/home.nix` into both integrated and standalone Home.
- Modules are grouped by class: `modules/{system,darwin,nixos,home}`. Each class
  `default.nix` is what every host of that class gets; other files are optional.
- Account files (preferences, casks, OS users) moved into their host.
- Home application modules declare casks with `dotfiles.casks`;
  `modules/darwin/homebrew.nix` collects them from integrated Homes.
- Ghostty's Darwin terminfo moved from the Darwin platform Home into
  `modules/home/ghostty.nix`. Both Darwin hosts select Ghostty.
- Removed: unmanaged host support (no host used it), `examples/`, the unused
  Linux-only aliases of the Darwin-only applications feature, and the
  aspect-resolution / account-composition tests.

## Output comparison

Snapshots from before and after the change were compared per host:

- Linux standalone and integrated Homes: identical derivations.
- Homebrew casks, brews and App Store apps: identical sets on both Macs.
- Darwin system defaults, fonts, launchd daemons/agents and system packages: equal.
- Darwin Homes: only the PATH position of `/Applications/Ghostty.app/Contents/MacOS`
  changed (now after the system profile and `/usr/local/bin`, previously before).
  It contains only the `ghostty` executable.
- NixOS `system-path`: the same 330 (blender) / 334 (ws-jh-song) package paths and
  otherwise identical attributes; only their order changed, with host-specific
  packages now preceding the shared ones. Order decides which package wins a file
  collision in `buildEnv`, so compare built `system-path` trees on a Linux builder.

## Validation

- `nix flake check --all-systems --no-build`: passed.
- `nix flake check` on Darwin: passed, including configuration policy, Darwin
  preferences, optional editors (casks via `dotfiles.casks`), GUI ownership,
  KeyRemapping migration and lint hooks.
- Both Darwin systems and both Darwin standalone Homes: built locally.
- Linux systems were evaluated only; build them on an x86_64-linux builder.

No activation was performed.
