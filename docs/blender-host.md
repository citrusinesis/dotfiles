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
- `hosts/blender/data-disk.nix` mounts a BitLocker-encrypted NTFS HDD shared with Windows at `/mnt/data`, through ntfs-3g and a key file outside the repository.
  BitLocker is the only encryption both systems open natively (`cryptsetup` reads BitLocker, while Windows has no maintained LUKS driver), and ntfs-3g is preferred over the faster ntfs3 driver because the HDD, not FUSE, bounds throughput.
  The disk is not managed by disko, so reinstalling NixOS never touches shared data; a GPT name set after Windows creates the partition keeps the mount free of machine-specific UUIDs.
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

## Upstream changes met along the way

- nixpkgs 26.11 removed the scripted initrd. The systemd initrd is the only implementation, so TPM2 unlock through `tpm2-device=auto` needs no extra option, and setting `boot.initrd.systemd.enable` is an error.

## Validation

- `nix flake check --all-systems --no-build`: passed, including the x86_64-linux configuration policy for `blender`.
- nixfmt, statix and deadnix: clean.
- `config.kdl` has not been validated: `niri validate` runs only on x86_64-linux, so the first build on the machine is the first check. Action names were compared against niri 26.04's source.
- `hosts/blender/hardware.nix` was written without the machine and has not been compared with `nixos-generate-config` yet.

Nothing was built for x86_64-linux or activated.
