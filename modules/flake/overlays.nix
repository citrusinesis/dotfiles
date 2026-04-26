{ inputs, ... }:

{
  flake.overlays.default =
    final: prev:
    (inputs.fenix.overlays.default final prev)
    // {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };

      claude-code = final.symlinkJoin {
        name = "claude-code";
        paths = [ inputs.claude-code.packages.${final.stdenv.hostPlatform.system}.default ];
        buildInputs = [ final.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/claude \
            --set CLAUDE_CODE_NO_FLICKER 1 \
            --set DISABLE_AUTOUPDATER 1
        '';
      };
    };
}
