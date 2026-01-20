{ inputs, ... }:

{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit.settings.hooks = {
        # Nix formatting
        nixfmt-rfc-style.enable = true;

        # Prevent committing secret files
        no-secrets = {
          enable = true;
          name = "no-secrets";
          entry = "${pkgs.writeShellScript "no-secrets" ''
            if git diff --cached --name-only | grep -q '\-local\.nix$'; then
              echo "ERROR: Attempting to commit *-local.nix files which contain secrets."
              echo "These files should remain staged but not committed."
              echo ""
              echo "To unstage them:"
              echo "  git reset HEAD -- '*-local.nix'"
              echo ""
              exit 1
            fi
          ''}";
          language = "system";
          pass_filenames = false;
          stages = [ "pre-commit" ];
        };
      };

      devShells.default = pkgs.mkShell {
        shellHook = config.pre-commit.installationScript;
      };
    };
}
