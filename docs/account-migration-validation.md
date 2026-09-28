# User / Host / Account migration validation

Validation date: 2026-09-07. Branch: `aspect`, uncommitted working tree.

The baseline was captured before this refactor, including the existing Apple
Container and launchd changes, at:

```text
/nix/store/izbc8dkkz7650w56f0in5cc2vc9zxfwr-source
```

The final implementation source archived for native Linux validation is:

```text
/nix/store/pp1w7qzngvg4a7a96svsppg5j995p7n4-source
```

The lock file and previously edited Apple Container, package, overlay, GPG and
launchd implementation files were preserved. This migration changes composition
and adds standalone Home outputs; it does not update dependencies.

## Configuration comparison

All four hosts matched the baseline for identity, home directories, state
versions, selected package names, Git identity/signing, Nix/Lix policy, GC and
timezone. Platform comparisons also matched:

- Darwin casks, brews, App Store IDs, fonts, PF/power settings and Container
  service ownership/configuration.
- Linux user/group IDs, supplementary groups, subuid/subgid ranges, sudo, SSH,
  Tailscale, Docker and power settings.
- macOS personal preferences after mapping nix-darwin's option names to their
  actual preference domains, including value types and both trackpad domains.
  The key-remapping label, arguments and RunAtLoad value are unchanged.

The deliberate PATH change puts `home.profileDirectory/bin` first. Integrated
Home uses `/etc/profiles/per-user/<user>/bin`; standalone Home uses its normal
user profile. This prevents the other activation form's older tools from taking
priority. The remaining PATH entries are preserved.

Personal macOS defaults and key remapping now belong to each User's Home.
Home Manager restarts Dock after applying preferences. The literal
`.GlobalPreferences` domain preserves the integer `AppleMetricUnits` value and
avoids two writers for the global domain. Container's service-specific defaults
remain with its native Host module.

Integrated and standalone outputs select the same application derivations.
Their normal Home Manager adapter differences remain: standalone adds the
Home Manager CLI; session variables use each form's profile directory; NixOS
integration adds font-cache placeholder directories.

## Checks

`nix flake check --all-systems --no-build` passed. Native `nix flake check` also
passed on both platforms, including Darwin GUI ownership, nixfmt, deadnix,
statix, shellcheck and private-key detection. Actionlint had no matching files.

Checks cover all registered integrated and standalone Home activation
derivations, plus fixtures on both platforms for:

- Multiple Accounts on a Host, without User/Account settings leaking.
- Host Home settings reaching every Account and shared file deduplication.
- Reusing one bound Account factory without losing native user definitions.
- Integrated, standalone, both and disabled modes, including their defaults
  and a managed Host with no Home Manager integration module.
- Unmanaged Linux and Darwin, custom Home/app directories, fonts, terminfo and
  settings-only optional Darwin editors.
- Invalid Account IDs/references, a mismatched primary Account/backend, missing
  Home state versions, unmanaged integration and username overrides.
- Canonical `user@host` outputs, detected Darwin hostname, XDG-based `NH_FLAKE`,
  Home parity, profile PATH priority and macOS preference ownership.

The shared backup default was also exercised in an isolated temporary directory:
two conflicting files with a space in their path produced two preserved backups.
Explicit `HOME_MANAGER_BACKUP_COMMAND` and `nh home -b` backup extensions retained
precedence over the default. No Home activation was run for this test.

## Native builds and nh

All registered systems and standalone Homes built successfully:

| Host | System build | Standalone Account build | Builder |
| --- | --- | --- | --- |
| `juicer` | Passed | `citrus@juicer`: passed | Local aarch64-darwin |
| `mixer` | Passed | `citrus@mixer`: passed | Local aarch64-darwin |
| `blender` | Passed | `citrus@blender`: passed | `capitol-workspace`, x86_64-linux |
| `ws-jh-song` | Passed | `jh-song@ws-jh-song`: passed | `capitol-workspace`, x86_64-linux |

The system outputs, in table order, are:

```text
/nix/store/sc0gmzbrpz5bpnmi6li5rlg9l6ak25pz-darwin-system-26.11.4cff07d
/nix/store/crj87y3ncy9jv62hb09x78aphdbx0h6w-darwin-system-26.11.4cff07d
/nix/store/iz7csd6c573g6574izrcpym89jy10294-nixos-system-blender-26.11.20260905.c043004
/nix/store/wps6r2c2kibd7h5ham6873ky72mbznxk-nixos-system-ws-jh-song-lxc-proxmox-26.11.20260905.c043004
```

The two Darwin Accounts currently produce the same Home contents. Standalone
Home outputs are:

```text
# citrus@juicer and citrus@mixer
/nix/store/r8b9l4sgihbgn4kl7v9z7yhmf1bkv5p6-home-manager-generation
# citrus@blender
/nix/store/4h8r634s891xm2n48y0wjafz61klf5c5-home-manager-generation
# jh-song@ws-jh-song
/nix/store/d4dsrmr4yjairkbvkbxkvf27q42dm97q-home-manager-generation
```

Pinned nh 4.4.2 exited successfully for automatic `darwin build` and `home build`
on `citrus@juicer`, and automatic `os build` and `home build` on
`jh-song@ws-jh-song`. No hostname or configuration selector was supplied.
Their result symlinks matched the corresponding system and Home outputs above.

```sh
nix flake check --all-systems --no-build
nix flake check --max-jobs 2 --cores 4
nix build --no-link --print-out-paths --max-jobs 2 --cores 4 \
  .#darwinConfigurations.juicer.system \
  .#darwinConfigurations.mixer.system \
  '.#homeConfigurations."citrus@juicer".activationPackage' \
  '.#homeConfigurations."citrus@mixer".activationPackage'

# On the registered Mac, with NH_FLAKE pointing to this checkout:
nix run .#nh -- darwin build --no-nom --diff never --no-write-lock-file
nix run .#nh -- home build --no-nom --diff never --no-write-lock-file
```

Linux validation archives the flake and its inputs with
`nix flake archive --to ssh://capitol-workspace`, then builds both native systems
and both standalone Homes from that store source over SSH. It does not alter the
builder's checkout. The pinned nh is run with `NH_FLAKE=path:<archived-source>`
and no `-H`/`-c`/installable argument, exercising discovery of `ws-jh-song` and
`jh-song@ws-jh-song`. The `path:` prefix distinguishes a store-resident flake
from an already-built result in nh.

## Activation boundary

No system switch, Home Manager activation, Homebrew operation, App Store
installation, old-profile removal or garbage collection was performed.

On the first actual switch, verify the User-owned defaults and key-remapping
agent in the login session, and open a fresh shell to check the active package
PATH. The previous [Darwin application checks](../README.md#first-application-after-migration)
still apply. Standalone Home does not install system-owned casks or change
native services/users. Existing standalone and integrated package generations
remain available until explicitly cleaned up.

## Activation follow-up: legacy key-remapping registration

The first user-run Darwin switch exposed a migration gap that build checks did
not catch. nix-darwin removed `/Library/LaunchAgents/com.local.KeyRemapping.plist`,
but its legacy `launchctl unload` call as root failed to remove the job from
`gui/501`. Home Manager then failed to bootstrap the same label with I/O error 5.
After the failure, `launchctl print` still reported the deleted system plist's
path, while the new plist already existed in the user's LaunchAgents directory.

The User's Home now runs `migrateLegacyKeyRemapping` after `writeBoundary` and
before `setupLaunchAgents`. It checks the registered job's path and boots out
only the legacy nix-darwin registration, even when its plist has already been
deleted. It uses `bootout --wait` on macOS 26 and newer, with the older-macOS
fallback used by [Home Manager's launchd activation](https://github.com/nix-community/home-manager/blob/2c0350c759688177331b8f5242311fae8877bdb3/modules/launchd/default.nix).
An existing Home Manager registration is left alone. Unload errors propagate;
dry runs do not change the registration.

The new regression check reproduces a partial activation with the new plist
already installed and the old registration still present. It also covers
repeated runs, missing and unrelated registrations, dry runs, unload failures
and both macOS command variants. The current platform's full flake check,
including shellcheck and the activation-order policy, passed. Both Darwin
systems and the standalone `citrus@juicer` Home built successfully.

The same migration was applied to the live `juicer` user domain, followed by
bootstrapping the already-installed Home Manager plist. `launchctl print` now
reports `/Users/citrus/Library/LaunchAgents/com.local.KeyRemapping.plist`, one run
and exit code 0. `hidutil` reported the expected Caps Lock → F18 mapping. Running
the migration again left the agent unchanged. No reboot or label change was
needed.

This follow-up repaired the user-domain registration. The full system switch
was not retried because noninteractive sudo required a password; the user can
complete it by running `nh darwin switch ~/.config/dotfiles` in their terminal.
