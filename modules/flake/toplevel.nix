{ inputs, ... }:

{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
    inputs.home-manager.flakeModules.home-manager
  ];

  perSystem =
    {
      config,
      lib,
      self',
      system,
      ...
    }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.self.overlays.default ];
        config.allowUnfree = true;
      };

      packageCandidates = self'.packages // pkgs.dotfilesPackages;

      updatablePackages = lib.filterAttrs (
        _name: package:
        lib.isDerivation package
        && lib.meta.availableOn pkgs.stdenv.hostPlatform package
        && package ? updateScript
      ) packageCandidates;

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
      _module.args.pkgs = pkgs;

      formatter = pkgs.nixfmt;
      legacyPackages = pkgs.dotfilesPackages;
      packages.default = self'.packages.activate;
      apps.update-pinned-packages = {
        type = "app";
        program = lib.getExe updatePinnedPackages;
      };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          bash
          gitleaks
          shellcheck
        ];
        shellHook = config.pre-commit.installationScript;
      };
    };
}
