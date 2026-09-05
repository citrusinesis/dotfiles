# Aspect migration validation

Validation dates: 2026-09-05–06. Implementation branch: `aspect`.
Baseline: clean `main` at `84a954f`. Configuration code: `202578a`;
subsequent changes are documentation only.

## Evaluation and regression checks

| Check | Result |
| --- | --- |
| `nix flake check --all-systems --no-build` | Passed for both platforms |
| Four embedded Home Manager activation derivations | Evaluated successfully |
| Composition-only aspect resolution | Passed |
| Same file included through a diamond | Applied once |
| Including a `provides` namespace | Does not select its children |
| Optional Kitty and VS Code on Darwin | Settings-only configuration and activation derivation evaluated |
| Custom `xdg.configHome` | nh uses the corresponding `dotfiles` path |
| Darwin casks and App Store IDs | Exact host-specific lists passed |
| Kitty, VS Code, Podman / Apple Container selection | Off on all current hosts / on both Darwin hosts |
| Darwin app linking and copying | Both explicitly disabled |
| Darwin `nix flake check` | Passed, including all ten native checks |
| Built Darwin application environments | No Nix-managed app bundles other than the permitted `pinentry-mac.app` |
| Linux `nix flake check` | Passed, including all seven native checks |
| Formatting and static checks | nixfmt, deadnix, statix, shellcheck, and private-key detection passed on both platforms |

The pre/post-migration snapshots matched for the four hosts' identity, home
directory, state versions, Nix/Lix settings, GC, editor and GPG settings, and
Home Manager integration. The comparison also covered Darwin PF/power/defaults,
fonts and Apple Container selection, and Linux user/group/subid, sudo, SSH,
Tailscale, power and Docker settings. The WSL and LXC host implementations and
the Apple Container/PF scripts were preserved when moved.

All retained flake input lock entries are unchanged. The lock changes only
add `flake-aspects` and remove `nixos-unified` and their root references.

## Actual builds

All four system builds passed on their native platforms. The embedded Darwin
Home Manager activation package was also built, not just evaluated.

| System | Actual build | Builder |
| --- | --- | --- |
| `juicer` | Passed | aarch64-darwin, local Mac |
| `mixer` | Passed | aarch64-darwin, local Mac |
| `blender` | Passed | x86_64-linux, `capitol-workspace` |
| `ws-jh-song` | Passed | x86_64-linux, `capitol-workspace` |

The successful system outputs, in the same host order, are:

```text
/nix/store/shm3hxy16s5bl82bmxvyfdcfxbnwq9ga-darwin-system-26.11.4cff07d
/nix/store/pizjqc958gp9grjqlr49ryyaxw6q1pp8-darwin-system-26.11.4cff07d
/nix/store/ssyz1lmrjg51yannqnrymdz4vknhjh1l-nixos-system-blender-26.11.20260831.34ab990
/nix/store/j7bcj6kfkz6a99xsdcy2srnxcdaavqr9-nixos-system-ws-jh-song-lxc-proxmox-26.11.20260831.34ab990
```

Linux validation uses `nix flake archive --to ssh://capitol-workspace` and builds
the resulting store source over SSH. It does not modify that machine's checkout
or activate a system configuration. The remote native flake check already passed.

The locked nh 4.4.2 successfully built both Darwin hosts and `ws-jh-song` (all
commands exited with status 0). On the local Mac, `/run/current-system` was
absent, so nh warned that it could not compare against the running system.
The system builds themselves succeeded. A separate `nix store diff-closures`
comparison against `/nix/var/nix/profiles/system` passed; this compares the saved
system profile, not a verified running generation. That profile predates the
baseline checkout, so its package-version differences are not flake input updates
made by this migration. No system symlink was changed to suppress the warning.
Concurrent Nix evaluations also emitted an ignored SQLite evaluation-cache-busy
warning.

The full build commands are:

```sh
nix flake check --max-jobs 2 --cores 4
nix build --no-link --print-out-paths --max-jobs 2 --cores 4 \
  .#darwinConfigurations.juicer.system \
  .#darwinConfigurations.mixer.system

nix run .#nh -- darwin build . -H juicer --no-nom --max-jobs 2 --cores 4
nix run .#nh -- darwin build . -H mixer --no-nom --max-jobs 2 --cores 4

# On the x86_64-linux builder, using the archived implementation source:
archivedSource=/nix/store/ncyhj8xx0xmcr000hzxzgf2c67fsyvr3-source
nix flake check "$archivedSource"
nix build --no-link --print-out-paths \
  "$archivedSource#nixosConfigurations.blender.config.system.build.toplevel" \
  "$archivedSource#nixosConfigurations.ws-jh-song.config.system.build.toplevel"

# This also passed and selected the same ws-jh-song system output:
nix run "$archivedSource#nh" -- os build "path:$archivedSource" \
  -H ws-jh-song --no-nom
```

The explicit `path:` prefix is necessary for an archived store source: nh treats
a bare `/nix/store/...` path as an already-built result, not as a flake. Normal
checkout paths such as `.` do not need this prefix.

## Existing pin repaired without a version update

The first Darwin build exposed an incorrect source hash in the existing Apple
Container 1.3.1 pin. The downloaded installer matched the SHA-256 digest published
by the [official release](https://github.com/apple/container/releases/tag/1.3.1).
`pkgutil --check-signature` confirmed an Apple Inc. Containerization distribution
signature and trusted Apple notarization. Only the source checksum was corrected;
the package version remains 1.3.1.

```text
SHA-256: a7c1b9d7927d30875f2f6c7bd1d0cb06c2daa6ca57ce9e90a5144e898fdf54a8
Nix SRI: sha256-p8G515J9MIdfL2x70dDLBsLapspXzp6QpRROiY/fVKg=
```

## Deliberately not executed

No system switch, Home Manager activation, Homebrew installation/update/cleanup,
or App Store installation was executed. No manually installed applications or
user data were deleted.

Homebrew metadata checks accepted the newly selected casks and the optional
VS Code cask. The unselected Kitty cask requires a Homebrew runtime that supports
its `command_wrapper` method; the initially installed Homebrew 6.0.10 did not.
Its Home Manager settings-only evaluation passed independently.

Cask installation, GUI launch, the native GPG prompt, CLI paths after activation,
and removal of the old Home Manager application link remain first-activation
checks, documented in the [README](../README.md#first-application-after-migration).
