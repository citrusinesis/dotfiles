{ inputs, ... }:

{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit.settings.hooks =
        let
          onPush = {
            enable = true;
            stages = [ "pre-push" ];
          };
        in
        {
          nixfmt.enable = true;
          detect-private-keys.enable = true;
          actionlint = onPush;
          deadnix = onPush;
          shellcheck = onPush;
          statix = onPush;
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
