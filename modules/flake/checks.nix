{
  config,
  inputs,
  lib,
  self,
  ...
}:

{
  perSystem =
    { pkgs, system, ... }:
    let
      features = config.dotfiles.aspects.features.provides;
      verify =
        name: results:
        let
          failures = builtins.attrNames (lib.filterAttrs (_: passed: !passed) results);
        in
        assert lib.assertMsg (failures == [ ]) "${name}: ${lib.concatStringsSep ", " failures}";
        pkgs.writeText name (builtins.toJSON results);

      evaluationCheck =
        name: drvPath:
        pkgs.runCommand name { evaluated = builtins.unsafeDiscardStringContext drvPath; } ''
          printf '%s\n' "$evaluated" > "$out"
        '';

      darwinChecks = lib.optionalAttrs (system == "aarch64-darwin") (
        lib.mapAttrs' (
          name: configuration:
          lib.nameValuePair "darwin-${name}-evaluation" (
            evaluationCheck "darwin-${name}-evaluation" configuration.system.drvPath
          )
        ) self.darwinConfigurations
      );

      nixosChecks = lib.optionalAttrs (system == "x86_64-linux") (
        lib.mapAttrs' (
          name: configuration:
          lib.nameValuePair "nixos-${name}-evaluation" (
            evaluationCheck "nixos-${name}-evaluation" configuration.config.system.build.toplevel.drvPath
          )
        ) self.nixosConfigurations
      );

      configurations =
        if pkgs.stdenv.hostPlatform.isDarwin then self.darwinConfigurations else self.nixosConfigurations;
      homeChecks = lib.mapAttrs' (
        name: configuration:
        let
          c = configuration.config;
          h = c.home-manager.users.${c.dotfiles.primaryUser};
        in
        lib.nameValuePair "home-${name}-evaluation" (
          evaluationCheck "home-${name}-evaluation" h.home.activationPackage.drvPath
        )
      ) configurations;

      optionalEditors = import ../../tests/optional-editors.nix { inherit features lib self; };
      applicationEnvironments = lib.concatMap (c: [
        c.config.system.build.applications
        c.config.home-manager.users.${c.config.system.primaryUser}.home.path
      ]) (builtins.attrValues self.darwinConfigurations);
    in
    {
      checks =
        darwinChecks
        // nixosChecks
        // homeChecks
        // {
          aspect-resolution = verify "aspect-resolution" (
            import ../../tests/aspect-resolution.nix { inherit inputs lib; }
          );
          configuration-policy = verify "configuration-policy" (
            import ../../tests/configuration-policy.nix { inherit lib self system; }
          );
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          optional-editors-policy = verify "optional-editors-policy" optionalEditors.checks;
          optional-editors-evaluation = evaluationCheck "optional-editors-evaluation" optionalEditors.activation;
          darwin-gui-ownership = pkgs.runCommand "darwin-gui-ownership" { } ''
            for profile in ${lib.escapeShellArgs (map toString applicationEnvironments)}; do
              for app in "$profile"/Applications/*.app; do
                if [ ! -e "$app" ] && [ ! -L "$app" ]; then continue; fi
                case "''${app##*/}" in
                  pinentry-mac.app) ;;
                  *) echo "Unexpected Nix-managed GUI application: $app" >&2; exit 1 ;;
                esac
              done
            done
            touch "$out"
          '';
        };
    };
}
