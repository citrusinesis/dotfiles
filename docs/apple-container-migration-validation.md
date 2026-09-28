# Apple Container module migration

Validated on 2026-09-07, on `juicer` (aarch64-darwin).

## Configuration

- `nix-apple-container` is locked to upstream commit
  `b7ecb6880de985c6fee25ca0088f50ae901f49ca`, using the existing nixpkgs input.
- Both Darwin hosts import the upstream `services.containerization` module.
- The selected CLI is 1.3.1 and the upstream Kata kernel is 3.26.0.
- No containers or Linux builders are declared.
- Local version/hash pins, the Home Manager runtime module, and
  `update-pinned-packages` have been removed.
- Existing working-tree lockfile changes were preserved; only the new input and
  its root reference were added during this migration.

The initial transition included a one-time Home Manager migration module, which
has now been removed. The feature retains runtime restart and Background-agent
refresh hooks. Its package override only adds TOML defaults; the version,
download hash, and signed binaries come from upstream.

## Verification

- `nix flake check --all-systems --no-build`: passed for both platforms.
- `nix flake check`: all 10 aarch64-darwin checks passed, including formatting,
  shell linting, Nix linting, configuration policy, and application ownership.
- Full `juicer` and `mixer` system builds passed. Linux builds were not run.
- CLI execution reports 1.3.1; strict code-signature checks pass for `container`
  and `container-apiserver` after adding the defaults file.
- The pinned kernel built successfully (16,151,040 bytes).
- Generated activation script syntax and migration/restart/setup ordering pass.
- Isolated shell simulations covered first migration, repeat migration, an
  unchanged runtime, changed package, changed kernel, a stopped runtime, and
  stop failure preserving the old migration markers for retry.

## Actual activation

`juicer` was switched to the new module. The system package diff contained only
Apple Container changes; Homebrew's installed packages matched the declaration.
The old Home Manager launch agent, config files, and markers were removed.
Upstream pruned the stopped `hello-world` and `buildkit` containers. Existing
machines and the named volume remained present.

Runtime status reports the new Nix package as its install root. The merged
configuration reports 8 CPUs, 4 GiB memory, and DNS domain `test`. The resolver is
installed, and `default.kernel-arm64` points to the pinned Nix store kernel.
The runtime's Background launch agent completed with exit status 0.
A second activation with the final automatic Background-agent refresh also
completed successfully. The system profile and `/run/current-system` both point
to the final build, and the refreshed agent again exited 0.

An ephemeral `container run --rm --name dotfiles-migration-smoke
docker.io/library/hello-world:latest` booted successfully and exited 0. Its
container record was automatically removed.

The first activation attempt through macOS's administrator helper failed with an
XPC connection error. Starting the verified runtime in the user session and
running activation through `launchctl asuser 501` resolved it. Normal `nh`
switches should be run from the user's terminal, as documented in the README.

## Remaining upstream limitations

- [Issue 8](https://github.com/halfwhey/nix-apple-container/issues/8) and
  [PR 9](https://github.com/halfwhey/nix-apple-container/pull/9) concern automatic
  container startup from GUI sessions. The fix was still unmerged. No declared
  workload's autostart is claimed as validated here.
- The current stale-apiserver check reads launchd's plist `path` rather than its
  `program` field, and truncates a path containing spaces. On this machine it
  deregistered a healthy apiserver during activation, causing an extra restart.
- The kernel is the upstream flake's 3.26.0 selection, not Container 1.3.1's
  suggested download. The smoke test above exercised that selected kernel.

`mixer` was built but was not activated remotely. The initial migration checks
did not include a reboot; the later `juicer` reboot verification is recorded below.

## Legacy cleanup on another machine

There is no longer an automatic migration hook. If `mixer` still has the old
Home Manager installation, unload its `org.nix-community.home.container-system-start`
and `org.nixos.container-system-start` jobs from the user's GUI and Background
domains, then stop the old container runtime before switching.

Remove only those two legacy plists from `~/Library/LaunchAgents`, the old
`$XDG_CONFIG_HOME/container/config.toml` (normally `~/.config/container/config.toml`),
and the copied snapshot at
`~/Library/Application Support/com.apple.container/config/config.toml`.
The old `managed-config.sha256`, `applied-config.sha256`, and `system-start.log`
under `$XDG_STATE_HOME/container` (normally `~/.local/state/container`) can also
be removed. No runtime data directory needs to be deleted for this cleanup.

## Follow-up: migration removal and Login Items name

The one-time migration file and its import have been removed. Neither legacy
cleanup nor its state detection appears in the resulting activation script.

The upstream module now receives a local script builder that emits `bin/<name>`
executables. Its bootstrap helper is named `apple-container-runtime`; the launchd
label remains `nix-apple-container.runtime`. The generated bootstrap script is
byte-for-byte identical to the original upstream script, and no global nixpkgs
script builder is overridden.

Both Darwin system builds and all 10 local flake checks passed after this change.
`juicer` was activated successfully. The Background agent exited 0, the runtime
remained healthy, and `sfltool dumpbtm` reported `Name: apple-container-runtime`
for both runtime records. The subsequent service audit below replaces the other
Nix services' `/bin/sh` entry points and repairs their registrations.

## Follow-up: service health and stable executable paths

The seven `sh` entries were traced to five required Nix jobs, a failing Home
Manager GPG agent, and the redundant Lix installer shell-repair job. They were
not seven copies of one service.

- Four core nix-darwin jobs now use real, root-owned launchers under
  `/Library/Scripts/nix-darwin`. Their original commands, triggers, sockets, and
  `/bin/wait4path /nix/store` guard are preserved. These paths stay stable across
  Nix generations and remain available before the Nix volume mounts.
- On `juicer`, nix-darwin now owns the installer's encrypted APFS store-mount
  job. Its OS-resident launcher preserves keychain-based unlocking and exits
  successfully if `/nix` is already mounted. The missing launchd registration
  was restored. Automatic unlocking was subsequently verified after a reboot.
- The Home Manager GPG launch agent was repeatedly exiting with status 2. Its
  Darwin launchd registration was disabled and removed; GPG's existing on-demand
  agent and socket remained usable. Linux's agent configuration is unchanged.
- The obsolete `systems.lix.nix-installer.nix-hook` job and plist were retired.
  The installer and its receipt remain available for recovery.
- Apple Container was stopped and started once to retire plugins still using
  the preceding Nix package. The API server and all three plugins then used the
  selected 1.3.1 package. Existing machines and the named volume remained present.

Both Darwin builds, all-platform evaluation, and all 10 native flake checks
passed. `juicer` was activated successfully. The system profile and
`/run/current-system` resolve to
`/nix/store/bzjiq2vrl4z29ifajgyk7y6iihk7vm26-darwin-system-26.11.4cff07d`.
The Nix daemon responded, activation and mount jobs exited 0, GC and optimisation
jobs were waiting for their schedules, and the Container API was healthy.

## Background-task database incident and recovery

During the local audit, the assistant mistakenly invoked `sfltool resetbtm
--help`. The tool ignored the unsupported help argument and reset the entire
login/background-item database. This was an unintended action, not a necessary
part of the Nix migration. No database reset is included in the configuration.

A text dump captured before the reset and the retired plists are preserved at
`~/.local/state/dotfiles/service-cleanup/2026-09-07/`. The pre-reset dump is named
`btm-before-accidental-reset.txt`; it records preferences but is not a restorable
binary database backup.

The five original Open at Login apps were restored: Cloudflare WARP, KakaoTalk,
MonitorControl, Raycast, and RunCatNeo. The Nix, Cloudflare, Logitech, and key
remapping launchd services were registered again and their operation checked.

The user approved restoring Notion/Slack's background preferences in System
Settings, then approved native UI restoration for Spotify, Tailscale, and Weather.

- Temporary Notion/Slack login entries were removed. A switch on a temporary
  login entry was insufficient to restore the original background-task policy.
  Notion later recreated its actual background-task record after being opened
  and quit. Its `8192.notion.id` record was then set to `disallowed`, verified in
  both System Settings and the database dump.
- Spotify and Tailscale's orphaned login helpers initially failed repeatedly
  with status 78 and were unloaded. They were subsequently registered again
  through the owning apps. Spotify's setting is back to `Minimized`; Tailscale's
  `Launch Tailscale at login` setting is on. Both native type-4 helper records are
  enabled and allowed, and both launchd jobs completed with exit status 0. The
  main apps remained running throughout the repair.
- Tailscale initially could not disable a helper whose registration was missing.
  Setting its documented `TailscaleStartOnLogin` user preference temporarily to
  false, reopening Settings, and enabling the checkbox let the app register its
  helper normally. The final preference is true; networking settings were not
  changed.
- Weather's menu-bar setting was reapplied to recreate its registration. The
  final background permission was matched against the pre-reset dump: enabled
  and allowed. Its menu helper is registered and running again. The initially
  observed menu-bar checkbox was read after the reset and must not be treated as
  evidence of the user's pre-reset preference.

Recovery is still incomplete for Slack's `8192.com.tinyspeck.slackmacgap`
background-task denial record. Opening/quitting Slack and checking for updates
did not recreate that record. There is currently no corresponding System
Settings switch to disable. Slack is not an Open at Login item, but its erased
background-task denial must not be reported as restored. Other inactive
background-task history can also be absent until apps register activity again.

macOS rejected external writes to the protected management APIs and a restart
of the Service Management daemon. No protection was bypassed. Apple recommends
restarting after a database reset in its
[background-task management documentation](https://support.apple.com/guide/deployment/manage-login-items-background-tasks-mac-depdca572563/web).
The user subsequently restarted the computer. This did not restore Slack's erased
preference automatically, as recorded below.

## Reboot verification on juicer

The user restarted `juicer` at 2026-09-07 02:30:24 KST. The system profile and
`/run/current-system` still resolve to the validated build above.

- The encrypted APFS Nix volume mounted automatically. The mount job ran once
  and exited 0; its log confirms that the volume was unlocked and mounted.
- `nix-daemon` started once and responded to `nix store ping --store daemon`.
  Startup activation ran once and exited 0. GC and optimisation remained
  scheduled, with no failed executions.
- `nix-apple-container.runtime` ran once and exited 0. The Container API started
  from the selected 1.3.1 store path and reported healthy without a manual start.
- GPG had no running agent initially. `gpg-connect-agent 'GETINFO pid'` started
  its on-demand agent successfully and returned a live PID. The removed Home
  Manager agent and installer repair job remained absent.
- Tailscale's login helper ran once and exited 0; its main app was running.
  Weather's menu helper started and remained running. Notion's background-task
  denial survived the reboot.
- The user confirmed that removing Cloudflare WARP and MonitorControl from Open
  at Login, and disabling KakaoTalk and Spotify's background permission, were
  intentional changes. Those settings were preserved. Spotify's absent launchd
  helper is consistent with its now-disallowed background registration.

Slack's background-task record was still absent after the restart and another
normal app launch/quit in the new login session. System Settings also had no
Slack background switch. The erased denial remains unresolved; the reboot must
not be described as having restored it. Registration snapshots are saved locally
under `~/.local/state/dotfiles/service-cleanup/2026-09-07/` as
`btm-after-reboot.txt` and `btm-after-reboot-app-check.txt`.
