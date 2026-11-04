# blender host — 2026-11-02

`blender` returns as a bare-metal desktop (Core Ultra 7 265K, RTX 5070) with niri and Plasma sessions, CUDA containers, and a disko-managed LUKS + btrfs disk.
Installation is described in [blender-install.md](blender-install.md).

## Changes

- `flake/hosts.nix` registers `blender` (x86_64-linux, `citrus`, Home state version 26.11); `flake.nix` adds the `disko` input.
- `modules/nixos/nvidia.nix` now describes a single discrete GPU driving the display.
  PRIME offload and fine-grained (RTD3) power management were laptop policy and needed bus IDs that only a physical machine has; a hybrid host enables them itself.
  It also adds `nvidia-vaapi-driver` for hardware video decoding.
- `modules/nixos/graphical.nix` keeps only what every desktop session shares (SDDM on Wayland, audio, networking, locale).
  The Plasma part moved to `plasma.nix` (formerly `desktop.nix`), and `niri.nix` adds a niri session through nixpkgs' `programs.niri`.
  Both import `graphical.nix`, so a host selects sessions, not a common base.
- `modules/nixos/i18n.nix` switches the input method from kime to fcitx5 with `fcitx5-hangul`, keeping kime's toggle keys (Hangul, Right Alt).
  KWin hands Wayland-native text input only to an input method speaking `input-method-v1`, while niri speaks `input-method-v2`.
  kime implements only v2, so under Plasma it was limited to GTK/Qt IM modules; fcitx5 implements both.
- `hosts/blender/btrfs.nix` runs snapper on `/home` only (24 hourly, 7 daily, 4 weekly, 3 monthly), since NixOS generations already roll back the system, and scrubs the filesystem monthly to detect silent corruption.
  The NixOS snapper module does not create the `.snapshots` subvolume, so disko creates it as the top-level `@snapshots-home`, which survives replacing `@home` with one of its snapshots.
- `hosts/blender/data-disk.nix` mounts the NTFS HDD shared with Windows at `/mnt/data` through ntfs-3g.
  Inspection on 2026-11-05 found an unencrypted `Data` volume at `/dev/sda2`, UUID `D652AEFA52AEDF0D`; the earlier planned BitLocker mapping is removed.
  The disk is not managed by disko, so reinstalling NixOS never touches shared data. The mount uses its filesystem UUID so disk enumeration changes do not affect it.
  Windows boots from the firmware menu rather than a systemd-boot entry, which would need a UEFI shell signed for Secure Boot.
- `modules/home/niri/` configures niri, waybar, fuzzel, mako, swaylock, swayidle and Plasma's polkit agent.
  `config.kdl` is plain KDL, checked with `niri validate` while the Home is built, so a config error fails the switch instead of niri falling back to its defaults.
  waybar, swayidle and the polkit agent are bound to `niri.service` and do not start under Plasma.
  The lock and idle tools follow niri's own documentation rather than the Hyprland tools carried over at first, which brought Hyprland's libraries along and, through the NixOS hyprlock module, Hyprland itself.
  catppuccin's swaylock theme is off because it reads its colors at evaluation time from a built source, which the Mac cannot evaluate for this host.
- niri replaced Hyprland before the first install.
  Hyprland 0.56 had just moved its configuration to Lua and Home Manager's generator was still catching up, while niri's KDL format has stayed stable; niri's scrolling layout also keeps windows at their width instead of splitting the screen further.
  niri-flake was tried for its typed `programs.niri.settings`, but its packages (25.08 and unstable) no longer evaluate against current nixpkgs, which removed `libdisplay-info_0_2`; nixpkgs ships niri 26.04.
  The GTK portal opens files instead of the GNOME one, which would require Nautilus.
  An NVIDIA application profile sets `GLVidHeapReuseRatio` to 0 for the `niri` process, as niri's documentation recommends; otherwise the driver keeps freed buffers and niri's VRAM use grows toward 1 GiB.
  SDDM starts niri by default, since both session modules propose a default and the host must choose.
- `modules/home/firefox.nix` installs Firefox from nixpkgs with policies that turn off telemetry, studies and sponsored suggestions and force-install uBlock Origin.
  Helium, the browser on the Macs, is not in nixpkgs; Firefox keeps security updates with nixpkgs, runs the full uBlock Origin that Chromium's Manifest V3 move cut down, and is the browser `nvidia-vaapi-driver` targets.
  catppuccin's Firefox theme is off for the same evaluation-time reason as its swaylock theme.
  blender forces Firefox's hardware video decoding through `nvidia-vaapi-driver` but keeps the RDD sandbox, which the driver's documentation says to disable; if decoding falls back to software, `about:support` (Media) shows it, and disabling the sandbox is a separate decision.

## Upstream changes met along the way

- nixpkgs 26.11 removed the scripted initrd. The systemd initrd is the only implementation, so TPM2 unlock through `tpm2-device=auto` needs no extra option, and setting `boot.initrd.systemd.enable` is an error.

## Validation before the first installation

- `nix flake check --all-systems --no-build`: passed, including the x86_64-linux configuration policy for `blender`.
- nixfmt, statix and deadnix: clean.
- `config.kdl` has not been validated: `niri validate` runs only on x86_64-linux, so the first build on the machine is the first check. Action names were compared against niri 26.04's source.
- `hosts/blender/hardware.nix` was written without the machine and has not been compared with `nixos-generate-config` yet.

Nothing was built for x86_64-linux or activated.

## Keyboard and GPU investigation — 2026-11-03

`hosts/blender/keyboard.nix` enables keyd and maps only Caps Lock to `hangeul`
(the evdev Hangul key), using the existing fcitx5 Hangul trigger in niri and
Plasma. Caps Lock switches languages without toggling letter case. The existing
Hangul and Right Alt triggers remain available. Ctrl, Alt, Super, application
shortcuts and niri window management bindings retain their original roles.
Terminal clipboard shortcuts remain Ctrl+Shift+C/V, with Ctrl+C for SIGINT.

The initial F18 mapping did not work: the default evdev/pc105/us XKB map
translates KEY_F18 into XF86Launch9, while fcitx5 was configured for F18.
Compiling that keymap with libxkbcommon confirmed KEY_HANGEUL resolves to
Hangul, matching the existing trigger.

### Journal findings

All times below are KST on 2026-11-03; driver is 615.78.08, open kernel module,
GPU is RTX 5070 at 0000:02:00.0.

- Boot `2ba80aa747614813be7374dbfe907bbf` (`-2` at investigation): at
  01:43:45, Xid 79, `GPU has fallen off the bus`, followed by GPU-lost RPC
  failures, TLB invalidation failures and memory teardown assertions. The
  first Xid is the primary finding; later messages may be consequences.
- Boot `6ff466ee364a455b8900cb76389ec67e` (current at investigation): 36
  `VM: invalid mmap context` messages at 02:21:29, immediately after niri's
  confirmed exit at 02:21:27 and during SDDM startup. No Xid in this boot at
  inspection. PipeWire also segfaulted during session teardown at 02:21:28.
- The other two retained boots had no NVRM errors in the inspected kernel
  logs. `nvidia-smi` currently responds normally.

[NVIDIA's Xid catalog](https://docs.nvidia.com/deploy/xid-errors/analyzing-xid-catalog.html)
identifies Xid 79 as loss of PCIe access to the GPU. It does not establish
whether this machine has a driver, firmware, link or power problem. Keep the
open kernel module required by Blackwell. No speculative ASPM, GSP or driver
changes were made from this single incident.

If it happens again, save evidence before rebooting if the machine responds:

```sh
journalctl -k -b --no-pager > /tmp/blender-kernel.log
journalctl -b --since '-10 minutes' --no-pager > /tmp/blender-session.log
nvidia-smi -q > /tmp/blender-nvidia-smi.log
sudo nvidia-bug-report.sh
```

Keep these reports outside git; they can contain machine and session details.
Record whether the trigger was idle, suspend, logout or GPU load. After a
power cycle, check GPU power connectors and seating with the machine off if
Xid 79 recurs, and collect PCIe/AER messages (`journalctl -k -b | rg -i
'aer|pcie|nvrm|xid'`). Compare a known working NixOS generation before trying
one driver or PCIe power setting change at a time. A successful evaluation
or rebuild cannot demonstrate that this intermittent GPU fault is fixed.

Apply the configuration with `nh os switch` and test Caps Lock in both
sessions. Check `systemctl status keyd` if keys are unchanged. No additional
fcitx5 trigger is required by the final Hangul mapping.

Validation: `keyd check` on the generated configuration and the generated
niri configuration's build-time validation passed. The complete NixOS system,
including NVIDIA modules, was built successfully. The initial F18 failure
was reported during keyboard testing; the mapping above replaces it.

## Desktop preferences — 2026-11-03

`hosts/blender/home.nix` selects 3840x2160 at 119.999 Hz and 125% scale for
Dell U2725QE serial 8DNMGF4, enables natural mouse scrolling, and overrides
Ghostty's font size to 12. Other hosts retain their defaults. The shared niri
module accepts extra top-level and input configuration from the host and
validates the combined KDL during the build.

## Latest kernel — 2026-11-03

`blender` overrides the shared `linuxPackages_6_12` default with
`pkgs.linuxPackages_latest`. The current lock resolves this to Linux 7.3.1;
future lock updates may advance that version. Other hosts keep their kernel
policy. NVIDIA's package is already selected from `boot.kernelPackages`, so
its kernel module follows this host's selected kernel.

The running kernel was 6.12.115 when this change was prepared. After applying
with `nh os switch`, reboot and check `uname -r`; switching alone does not
replace the running kernel. Keep the previous NixOS generation available in
the boot menu. Check desktop responsiveness, suspend/resume, CUDA workloads
and NVRM/Xid logs before comparing CachyOS patches as a separate change.
No CachyOS patches are included at this stage.

After the user applied the configuration and rebooted, `uname -r` reported
7.3.1 and `nvidia-smi` responded with driver 615.78.08. At about one minute
of uptime, the current boot had no NVRM errors. This is an initial boot check,
not evidence that the earlier intermittent Xid 79 issue is resolved.

## niri and Noctalia — 2026-11-04

The selected desktop is niri 26.04 with Noctalia 5.4.1 and Noctalia Greeter 1.7.0,
all from the locked nixpkgs input. Plasma, SDDM, Umbriel, Waybar, Fuzzel, Mako,
Swaylock, Swayidle, and the separate KDE authentication agent are removed from
this host's composition. Noctalia provides the bar, launcher, notifications,
control center, manual session lock, and Polkit agent; greetd runs its greeter.
Automatic lock and screen-off timers retain Noctalia's disabled defaults.

niri includes its packaged default configuration, excluding Waybar autostart.
The default key positions are preserved: Super+T opens Ghostty, Super+D opens
the Noctalia launcher, and Super+Alt+L locks through Noctalia. The monitor's
3840×2160 at 119.999 Hz,
125% scale, natural mouse scrolling, Ghostty font size 12, and keyd's Caps Lock
Hangul mapping are retained.

Noctalia owns the shared Qt/GTK/Ghostty palette; Qt uses Fusion through qtct,
and GTK uses adw-gtk3 with generated colors. The shell and Zed follow the local
07:00–19:00 light schedule. The shell uses glass panels and a translucent bar.
No custom wallpaper is installed. Greeter appearance sync is restricted to the
primary active local user and the packaged appearance-only helper.

The cursor is Bibata Modern Ice, size 24, shared by the greeter, niri, GTK,
Xcursor environment and X11 resources. Home Manager replaces the stale Breeze
cursor setting in dconf. The cursor package and default-theme links are installed
for applications that use theme-name fallback.

The complete system builds, both configurations validate, and the generated
Noctalia palette validates as part of the niri configuration. Greeter, compositor,
GTK and standalone Home settings agree on the cursor theme and size. Actual
login and pointer appearance across apps still need checking after reboot.
DDC brightness access is enabled; monitor support and DDC/CI must still be
checked on the actual display.

Apply this display-manager change at the next boot rather than replacing the
running desktop in place:

```sh
nh os boot
systemctl reboot
```

The user confirmed a successful boot into this composition. A subsequent live
rendering check found that forcing blur on every `noctalia-*` layer also blurred
the full-screen outside-click shield. The niri rule now leaves blur regions to
Noctalia and selects non-xray blur only for its bar, notification, dock, panel,
attached-panel and OSD surfaces. The wallpaper and click shield are excluded.
Focus decoration no longer fills transparent window backgrounds; Ghostty has
an explicit window blur rule. The focus ring is one logical pixel wide, with
12-pixel rounded, clipped window geometry. App-provided GTK headerbars remain.

Live checks covered the launcher, control center, notification history, session
menu, clipboard, volume OSD and floating Noctalia settings window. Their UI stays
over the existing windows without full-screen blur. Lock and greeter rendering
were not exercised during this check. The rendering configuration was loaded
into the running niri session; `nh os switch` persists it without a reboot.

Font preferences use Pretendard for sans-serif UI text and Hack Nerd Font Mono
with D2KodingLigature Nerd Font as the first monospace fallback. Linux fontconfig
declares these defaults and the fallback for explicit Hack requests; Ghostty
declares the same two-family chain. Zed uses Pretendard for its UI and retains
Hack/D2KodingLigature for editor and terminal text. The shared VS Code font list
also uses the installed D2KodingLigature family spelling. Existing sizes remain.
Checks against the generated fontconfig rules selected Pretendard for Latin and
Hangul sans-serif, Hack for Latin monospace, and D2KodingLigature for Hangul
monospace. Ghostty validation, the system build, configuration policy check and
Darwin configuration evaluation passed. Apply with `nh os switch`, then reopen
apps to refresh their font selection.
