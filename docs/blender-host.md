# blender host — 2026-11-02

`blender` returns as a bare-metal desktop (Core Ultra 7 265K, RTX 5070) with Plasma and Hyprland sessions, CUDA containers, and a disko-managed LUKS + btrfs disk.
Installation is described in [blender-install.md](blender-install.md).

## Changes

- `flake/hosts.nix` registers `blender` (x86_64-linux, `citrus`, Home state version 26.11); `flake.nix` adds the `disko` input.
- `modules/nixos/nvidia.nix` now describes a single discrete GPU driving the display.
  PRIME offload and fine-grained (RTD3) power management were laptop policy and needed bus IDs that only a physical machine has; a hybrid host enables them itself.
  It also adds `nvidia-vaapi-driver` for hardware video decoding.
- `modules/nixos/graphical.nix` keeps only what every desktop session shares (SDDM on Wayland, audio, networking, locale).
  The Plasma part moved to `plasma.nix` (formerly `desktop.nix`), and `hyprland.nix` adds a UWSM-managed Hyprland session.
  Both import `graphical.nix`, so a host selects sessions, not a common base.
- `modules/nixos/i18n.nix` switches the input method from kime to fcitx5 with `fcitx5-hangul`, keeping kime's toggle keys (Hangul, Right Alt).
  KWin hands Wayland-native text input only to an input method speaking `input-method-v1`, while Hyprland speaks `input-method-v2`.
  kime implements only v2, so under Plasma it was limited to GTK/Qt IM modules; fcitx5 implements both.
- `hosts/blender/btrfs.nix` runs snapper on `/home` only (24 hourly, 7 daily, 4 weekly, 3 monthly), since NixOS generations already roll back the system, and scrubs the filesystem monthly to detect silent corruption.
  The NixOS snapper module does not create the `.snapshots` subvolume, so disko creates it as the top-level `@snapshots-home`, which survives replacing `@home` with one of its snapshots.
- `hosts/blender/data-disk.nix` mounts a BitLocker-encrypted NTFS HDD shared with Windows at `/mnt/data`, through ntfs-3g and a key file outside the repository.
  BitLocker is the only encryption both systems open natively (`cryptsetup` reads BitLocker, while Windows has no maintained LUKS driver), and ntfs-3g is preferred over the faster ntfs3 driver because the HDD, not FUSE, bounds throughput.
  The disk is not managed by disko, so reinstalling NixOS never touches shared data; a GPT name set after Windows creates the partition keeps the mount free of machine-specific UUIDs.
  Windows boots from the firmware menu rather than a systemd-boot entry, which would need a UEFI shell signed for Secure Boot.
- `modules/home/hyprland.nix` configures Hyprland, waybar, fuzzel, mako, hyprlock, hypridle and the polkit agent.

## Upstream changes met along the way

- nixpkgs 26.11 removed the scripted initrd. The systemd initrd is the only implementation, so TPM2 unlock through `tpm2-device=auto` needs no extra option, and setting `boot.initrd.systemd.enable` is an error.
- Hyprland 0.56 reads `hyprland.lua` first and falls back to `hyprland.conf` only through its legacy config manager.
  Home Manager generates Lua for Homes with state version 26.05 or later, where each `settings` attribute becomes an `hl.<name>(...)` call.
  The hyprlang-style values (`"$mod, Q, killactive,"`) therefore produce invalid Lua; binds are written as `hl.bind("SUPER + Q", hl.dsp.window.close())`.
  `hyprctl dispatch` takes the same dispatcher expressions, which hypridle's DPMS commands use.

## Validation

- `nix flake check --all-systems --no-build`: passed, including the x86_64-linux configuration policy for `blender`.
- nixfmt, statix and deadnix: clean.
- The generated `hyprland.lua` runs to completion under Lua 5.5 against a stub `hl` table. It has not been loaded by Hyprland; check `hyprctl configerrors` after the first login.
- `hosts/blender/hardware.nix` was written without the machine and has not been compared with `nixos-generate-config` yet.

Nothing was built for x86_64-linux or activated.
