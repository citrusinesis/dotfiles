# blender installation

`blender` is a bare-metal x86_64 desktop (Core Ultra 7 265K, RTX 5070).
disko owns its disk layout, so a first install partitions the disk from `hosts/blender/disko.nix` instead of reusing an existing installation.
Stage 1 erases the target disk. Stage 2 changes the existing installation without repartitioning.

| Partition | Content |
| --- | --- |
| `disk-blender-ESP` (1 GiB) | vfat, mounted at `/boot` |
| `disk-blender-luks` (rest) | LUKS2 `cryptroot` → btrfs `@root` `/`, `@home` `/home`, `@snapshots-home` `/home/.snapshots`, `@nix` `/nix`, `@swap` `/swap` (16 GiB swapfile) |

Unlocking happens in two stages.
Stage 1 installs with a LUKS passphrase.
Stage 2 adds Secure Boot through lanzaboote and then a TPM2 key slot, after which boot no longer asks for the passphrase.
The `tpm2-device=auto` crypttab option is already set; without an enrolled TPM2 slot it falls back to the passphrase.

## Before you start

The live system clones this repository from GitHub, so the configuration to install must be committed and pushed first.

Build the boot USB from the NixOS graphical ISO; the minimal ISO works the same way without the live desktop.
On macOS, verify the image against the checksum published next to it, find the USB disk, and write the image to its raw device:

```bash
iso=nixos-graphical-26.05.13297.fa1373130d5a-x86_64-linux.iso
curl -fsSL "https://releases.nixos.org/nixos/26.05/nixos-26.05.13297.fa1373130d5a/$iso.sha256"
shasum -a 256 "$iso"

diskutil list external physical
diskutil unmountDisk /dev/diskN
sudo dd if="$iso" of=/dev/rdiskN bs=4M status=progress && sync && diskutil eject /dev/diskN
```

`/dev/rdiskN` bypasses the buffer cache and is much faster than `/dev/diskN`.
The Nix-provided GNU `dd` takes `bs=4M`; macOS `/bin/dd` takes `bs=4m`.
If macOS then reports the disk as unreadable, choose Eject or Ignore, not Initialize.

## Stage 1: install

Firmware settings: UEFI boot, Secure Boot off for now, Intel PTT (firmware TPM) on.

Boot the USB.
The graphical ISO starts a live KDE session: connect to the network from the panel and open Konsole.
On the minimal ISO, use `nmtui` for Wi-Fi.
Then become root and identify the target disk:

```bash
sudo -i
lsblk -o NAME,SIZE,MODEL
```

The layout targets `/dev/nvme0n1`.
If the intended disk has another name, change `device` in `hosts/blender/disko.nix` before partitioning; after installation the device name is no longer read, because every mount uses partition labels.

```bash
git clone https://github.com/citrusinesis/dotfiles /tmp/dotfiles
cd /tmp/dotfiles
export NIX_CONFIG="experimental-features = nix-command flakes"

# Asks for confirmation, then for the LUKS passphrase twice.
nix run --inputs-from . disko -- --mode destroy,format,mount --flake .#blender
```

`--inputs-from .` runs the disko revision pinned in `flake.lock`, the same one that generates the mounts in the installed system.

The current configuration includes lanzaboote. Before `nixos-install`, generate
its signing keys on the mounted target so bootloader installation can sign the
images. This step is only for a fresh installation, with Secure Boot still off:

```bash
cat > /tmp/sbctl-install.yaml <<'EOF'
keydir: /mnt/var/lib/sbctl/keys
guid: /mnt/var/lib/sbctl/GUID
EOF
nix run nixpkgs#sbctl -- --config /tmp/sbctl-install.yaml create-keys
```

The live ISO only knows `cache.nixos.org`, so pass the repository's caches to the install; otherwise packages such as the coding agents are compiled locally.
The NVIDIA kernel module is unfree and is built locally either way, which takes a few minutes.

```bash
nixos-install --flake .#blender --no-root-passwd \
  --option extra-substituters "https://nix-community.cachix.org https://cache.numtide.com https://fenix.cachix.org" \
  --option extra-trusted-public-keys "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g= fenix.cachix.org-1:ecJhr+RdYEdcVgUkjruiYhjbBloIEGov7bos90cZi0Q="

# Root stays locked; citrus administers through sudo.
nixos-enter --root /mnt -c 'passwd citrus'
reboot
```

After the first login:

```bash
git clone git@github.com:citrusinesis/dotfiles.git ~/.config/dotfiles
nh os switch
```

- SDDM starts `niri` by default and also offers `Plasma (Wayland)`. In niri, `Super+Shift+/` lists the key bindings.
- If niri's VRAM use in `nvtop` approaches 1 GiB, check that `/etc/nvidia/nvidia-application-profiles-rc.d/50-niri.json` exists; the driver reads it when niri starts.
- In Plasma, select Fcitx 5 under System Settings → Keyboard → Virtual Keyboard so Wayland-native apps receive Korean input.
- snapper snapshots `/home` hourly and keeps 24 hourly, 7 daily, 4 weekly and 3 monthly snapshots. Check with `snapper -c home list`; restore with `snapper -c home undochange <old>..<new> <path>` or by copying from `/home/.snapshots/<n>/snapshot`. Snapshots live on the same disk and are not a backup. A monthly `btrfs scrub` verifies every block against its checksum; see the last result with `sudo btrfs scrub status /`.
- Back up the LUKS header and keep the file off this disk; a damaged header makes the disk unreadable even with the passphrase: `sudo cryptsetup luksHeaderBackup /dev/disk/by-partlabel/disk-blender-luks --header-backup-file luks-header.img`.
- `hosts/blender/hardware.nix` was written without the machine. Compare it with `nixos-generate-config --no-filesystems --show-hardware-config` and add any kernel modules it lists that are missing.

## Stage 2: Secure Boot and TPM unlock

The configuration already imports lanzaboote and signs boot images with
`/var/lib/sbctl/keys/db/db.key`. Key generation and firmware enrollment are
manual; the configuration does not automatically replace firmware certificates.
See the [lanzaboote setup guide](https://nix-community.github.io/lanzaboote/getting-started/prepare-your-system.html).

### Prepare the installed host

1. Create the signing keys (once; skip if already generated during Stage 1). Keep private keys on the encrypted root,
   outside the repository and Nix store:

   ```bash
   sudo nix run nixpkgs#sbctl -- create-keys
   ```

2. Install the prepared configuration for the next boot:

   ```bash
   nh os boot
   sudo nix run nixpkgs#sbctl -- verify
   ```

   Check that `/boot/EFI/BOOT/BOOTX64.EFI`, the systemd-boot EFI binary and
   `/boot/EFI/Linux/nixos-generation-*.efi` are signed. Old standalone kernel
   files under `/boot/EFI/nixos/` may be reported unsigned; these are distinct
   from the signed lanzaboote boot images.

3. Export only the public db certificate in DER format to the Linux ESP:

   ```bash
   sudo install -d -m 0700 /boot/secureboot
   sudo nix shell nixpkgs#openssl -c openssl x509 \
     -in /var/lib/sbctl/keys/db/db.pem -outform DER \
     -out /boot/secureboot/blender-db.cer
   ```

   If the firmware file picker cannot read the internal ESP, copy this `.cer`
   file to a FAT32 USB drive. Do not copy the private `.key` files.

### Preserve the firmware's existing certificates

On 2026-11-05, `blender` reported an ASUS ROG STRIX B860-I GAMING WIFI board,
Secure Boot disabled and Setup Mode disabled. The enrolled PK belongs to ASUS;
KEK contains ASUS and Microsoft 2011/2023 certificates, and db contains ASUS,
Microsoft UEFI 2011/2023 and Windows 2011/2023 certificates. dbx is populated.
The user confirmed that the Windows system drive does not use BitLocker.

After manual certificate enrollment and reboot on 2026-11-05, `bootctl status`
reported `Secure Boot: enabled (user)`, `Measured UKI: yes`, and lanzastub 1.2.0
booting generation 16. Reading db with `efi-readvar` confirmed that the original
ASUS/Microsoft certificates and image hashes remain, with `CN=Database Key`
appended. `systemd-analyze has-tpm2` reported all firmware, driver, subsystem
and library checks present. After manual TPM enrollment, the header backup at
`/mnt/data/blender-luks-header.img` was parsed successfully: keyslots 0 and 1
exist, with a `systemd-tpm2` token using slot 1 and PCR 7. The backup resides on
the separate HDD (`/dev/sda2`). The user confirmed automatic root unlock after
reboot; the existing passphrase slot is retained for recovery.

Use the firmware's custom key management to **append** `blender-db.cer` to db
(the allowed signature database), preserving PK, KEK, the existing db entries
and dbx. Do not use `sbctl enroll-keys --microsoft`, clear all keys, or replace
the existing databases for this workflow. Do not clear the TPM.

On ASUS firmware, look under Boot → Secure Boot → Custom → Key Management →
DB Management → Append Key. Menu names and supported certificate formats need
checking in the actual BIOS. If append is unavailable, leave the existing keys
in place and resolve enrollment before enabling enforcement. Keep Secure Boot
disabled until the signed boot files and db certificate are ready.

Enable Secure Boot (ASUS may call the OS Type setting “Windows UEFI mode”),
then boot NixOS and check:

```bash
bootctl status
sudo sbctl list-enrolled-keys
```

Require `Secure Boot: enabled (user)` and confirm that db includes the new
certificate alongside the original ASUS/Microsoft entries. Test Windows boot
as well. If Linux is rejected, disable Secure Boot temporarily to return to
NixOS and inspect enrollment and signatures; keep the existing keys.

For a future Windows installation with TPM-backed BitLocker, save its recovery
key and suspend BitLocker protection before changing firmware certificates,
then resume it in Windows after completing the change.

### Enroll LUKS in the final Secure Boot state

Back up the LUKS header off this disk before enrollment. Optionally generate
an offline recovery key, then enroll TPM2:

```bash
sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-blender-luks --recovery-key
sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-blender-luks --tpm2-device=auto --tpm2-pcrs=7
```

Reboot and check that root unlocks without a prompt. `tpm2-device=auto` is
already configured in `hosts/blender/disko.nix`.

PCR 7 binds this enrollment to the Secure Boot policy and authorities; it is
not a measurement of a specific kernel or command line. Keeping Microsoft
certificates broadens the set of trusted boot software. This simple policy
does not provide the same restriction as binding to an approved Linux image
with an additional measured-boot policy. See
[systemd-cryptenroll](https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptenroll.html).

Keep the passphrase slot.
Changing the Secure Boot keys or certain firmware updates change PCR 7, and boot falls back to the passphrase.
Re-enroll afterwards with `sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-blender-luks --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7`.

## Windows and the shared HDD

Windows lives on its own SSD and is started from the firmware boot menu; systemd-boot does not list it.
A systemd-boot entry for an ESP on another disk needs a UEFI shell, which would have to be signed and trusted once Secure Boot is on.

The HDD is shared as an NTFS volume encrypted with BitLocker.
NixOS opens it with the BitLocker password from a key file on the encrypted root and mounts it at `/mnt/data`.
`hosts/blender/data-disk.nix` declares both with `nofail`, so boot is unaffected until the disk is prepared.
BitLocker's TPM protector only works under Windows; on NixOS the disk unlocks without a prompt once the root does, because the key file lives there.

### Windows

1. Install Windows with the NVMe disconnected or disabled in the firmware. Otherwise the installer puts its boot files on blender's ESP.
2. Disable hibernation and Fast Startup, which leave NTFS volumes marked in use and make ntfs-3g refuse to mount them: `powercfg /h off`.
3. Keep the hardware clock in UTC, as NixOS does: `reg add "HKLM\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f`.
4. If the Windows system drive will use BitLocker with the TPM, finish Stage 2 first. Enrolling Secure Boot keys afterwards changes PCR 7, and Windows then asks for its recovery key.

### HDD

1. In Disk Management, initialize the HDD as GPT and create one NTFS volume.
2. Turn on BitLocker for it with "Use a password to unlock the drive", and store the recovery key off the machine. Automatic unlocking in Windows is optional and requires a BitLocker system drive.
3. Boot NixOS and give the BitLocker partition the label the configuration expects. GPT names are invisible to Windows and BitLocker.

   ```bash
   lsblk -o NAME,SIZE,FSTYPE,PARTLABEL   # FSTYPE BitLocker; usually partition 2 after the MSR partition
   sudo nix shell nixpkgs#gptfdisk -c sgdisk -c 2:blender-data /dev/sdX
   sudo udevadm trigger
   ```

4. Store the BitLocker password as the key file. systemd-cryptsetup uses the whole file as the password, so it must not end with a newline:

   ```bash
   sudo install -d -m 0700 /etc/cryptsetup-keys.d
   sudo sh -c 'umask 077; IFS= read -rs p; printf %s "$p" > /etc/cryptsetup-keys.d/data.key'
   ```

5. Open and check it, or reboot:

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start systemd-cryptsetup@data.service
   ls /mnt/data
   ```

The key file is not in this repository; restore it after a reinstall.
Never write to the HDD from NixOS while Windows is hibernated.
