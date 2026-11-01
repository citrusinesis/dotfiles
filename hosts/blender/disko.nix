{ ... }:

let
  btrfsOptions = [
    "compress=zstd"
    "noatime"
  ];
in
{
  disko.devices.disk.blender = {
    type = "disk";
    device = "/dev/nvme0n1";

    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings = {
              allowDiscards = true;
              bypassWorkqueues = true;
              crypttabExtraOpts = [ "tpm2-device=auto" ];
            };

            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = btrfsOptions;
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = btrfsOptions;
                };
                "@snapshots-home" = {
                  mountpoint = "/home/.snapshots";
                  mountOptions = btrfsOptions;
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = btrfsOptions;
                };
                "@swap" = {
                  mountpoint = "/swap";
                  swap.swapfile.size = "16G";
                };
              };
            };
          };
        };
      };
    };
  };
}
