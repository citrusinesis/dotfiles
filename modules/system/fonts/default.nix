{ pkgs, lib, ... }:
let
  appearance = import ../../../lib/desktop-appearance.nix;
in
{
  fonts = {
    packages = import ./packages.nix { inherit pkgs lib; };
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    fontconfig = {
      defaultFonts = {
        sansSerif = [
          appearance.font
          "Noto Sans CJK KR"
        ];
        monospace = [
          appearance.monospaceFont
          appearance.monospaceFallback
        ];
      };
      # Apply the same fallback to apps requesting Hack explicitly.
      localConf = ''
        <alias binding="strong">
          <family>${appearance.monospaceFont}</family>
          <accept><family>${appearance.monospaceFallback}</family></accept>
        </alias>
      '';
    };
  };
}
