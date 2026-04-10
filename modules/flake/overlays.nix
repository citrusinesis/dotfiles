{ inputs, ... }:

{
  flake.overlays.default = final: _prev: {
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
          --set CLAUDE_CODE_NO_FLICKER 1
      '';
    };
  };
}
