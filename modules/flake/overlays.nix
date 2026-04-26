{ inputs, ... }:

{
  flake.overlays.default =
    final: prev:
    (inputs.fenix.overlays.default final prev)
    // (inputs.nix-vscode-extensions.overlays.default final prev)
    // {
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
