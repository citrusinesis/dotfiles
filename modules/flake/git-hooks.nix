{ inputs, ... }:

{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit.settings.hooks = {
        # Nix formatting
        nixfmt-rfc-style.enable = true;
      };

      devShells.default = pkgs.mkShell {
        shellHook = config.pre-commit.installationScript;
      };
    };
}
