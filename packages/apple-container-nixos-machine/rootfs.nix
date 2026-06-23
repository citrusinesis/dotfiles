{
  pkgs,
  lib,
  targetSystem ? null,
}:

let
  linuxSystem =
    if targetSystem != null then
      targetSystem
    else if pkgs.stdenv.hostPlatform.isAarch64 then
      "aarch64-linux"
    else
      "x86_64-linux";

  nixos = import "${pkgs.path}/nixos" {
    system = linuxSystem;
    configuration = {
      imports = [ ./configuration.nix ];
      nixpkgs.hostPlatform = linuxSystem;
    };
  };
in
nixos.config.system.build.containerMachineRootfs.overrideAttrs (_: {
  name = "apple-container-nixos-machine-rootfs-${linuxSystem}";

  passthru = {
    targetSystem = linuxSystem;
    inherit nixos;
  };

  meta = {
    description = "NixOS rootfs tarball for Apple container machine";
    platforms = lib.platforms.linux;
  };
})
