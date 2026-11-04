{ config, ... }:

let
  owner = config.users.users.${config.dotfiles.primaryUser};
in
{
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/D652AEFA52AEDF0D";
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
