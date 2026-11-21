{ lib, self, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
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
    in
    {
      checks = darwinChecks;
    };
}
