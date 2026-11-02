{ config, ... }:

let
  owner = config.users.users.${config.dotfiles.primaryUser};
in
{
  environment.etc.crypttab.text = ''
    data /dev/disk/by-partlabel/blender-data /etc/cryptsetup-keys.d/data.key bitlk,nofail
  '';

  fileSystems."/mnt/data" = {
    device = "/dev/mapper/data";
    fsType = "ntfs-3g";
    options = [
      "uid=${toString owner.uid}"
      "gid=${toString config.users.groups.${owner.group}.gid}"
      "dmask=022"
      "fmask=133"
      "windows_names"
      "nofail"
      "x-systemd.automount"
      "x-systemd.device-timeout=10s"
    ];
  };
}
