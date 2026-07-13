{ inputs, ... }:

{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
    inputs.home-manager.flakeModules.home-manager
  ];

  perSystem =
    {
      lib,
      self',
      pkgs,
      ...
    }:
    let
      updatablePackages = lib.filterAttrs (
        _name: package: lib.isDerivation package && package ? updateScript
      ) self'.packages;

      updatePackage = name: package: ''
        echo "==> Updating ${name}"
        ${lib.escapeShellArgs (lib.toList (package.updateScript.command or package.updateScript))}
      '';

      updatePinnedPackages = pkgs.writeShellApplication {
        name = "update-pinned-packages";
        text = lib.concatStringsSep "\n" (lib.mapAttrsToList updatePackage updatablePackages);
      };
    in
    {
      formatter = pkgs.nixfmt;
      packages.default = self'.packages.activate;
      apps.update-pinned-packages = {
        type = "app";
        program = lib.getExe updatePinnedPackages;
      };
    };
}
