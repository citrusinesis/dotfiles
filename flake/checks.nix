{
  hosts,
  lib,
  self,
  ...
}:

{
  perSystem =
    { pkgs, system, ... }:
    let
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
      homeChecks = lib.foldlAttrs (
        checks: host: configuration:
        checks
        // lib.mapAttrs' (
          user: h:
          lib.nameValuePair "home-integrated-${user}@${host}-evaluation" (
            evaluationCheck "home-integrated-${user}@${host}-evaluation" h.home.activationPackage.drvPath
          )
        ) (configuration.config.home-manager.users or { })
      ) { } configurations;
      standaloneChecks = lib.mapAttrs' (
        name: h:
        lib.nameValuePair "home-standalone-${name}-evaluation" (
          evaluationCheck "home-standalone-${name}-evaluation" h.activationPackage.drvPath
        )
      ) (lib.filterAttrs (_: h: h.pkgs.stdenv.hostPlatform.system == system) self.homeConfigurations);

      optionalEditors = import ../tests/optional-editors.nix { inherit lib self; };
      applicationEnvironments =
        lib.concatMap (
          c:
          [ c.config.system.build.applications ]
          ++ map (h: h.home.path) (builtins.attrValues (c.config.home-manager.users or { }))
        ) (builtins.attrValues self.darwinConfigurations)
        ++ map (h: h.config.home.path) (
          builtins.attrValues (
            lib.filterAttrs (_: h: h.pkgs.stdenv.hostPlatform.isDarwin) self.homeConfigurations
          )
        );
    in
    {
      checks =
        darwinChecks
        // nixosChecks
        // homeChecks
        // standaloneChecks
        // {
          configuration-policy = verify "configuration-policy" (
            import ../tests/configuration-policy.nix {
              inherit
                hosts
                lib
                self
                system
                ;
            }
          );
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          darwin-preferences-policy = verify "darwin-preferences-policy" (
            import ../tests/darwin-preferences.nix { inherit lib self; }
          );
          key-remapping-migration = import ../tests/key-remapping-migration.nix {
            inherit pkgs lib;
            script =
              self.homeConfigurations."citrus@juicer".config.home.activation.migrateLegacyKeyRemapping.data;
          };
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
