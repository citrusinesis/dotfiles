{ inputs, ... }:

{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem = {
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
  };
}
