{
  fetchFromGitHub,
  runCommand,
}:
let
  catppuccin = fetchFromGitHub {
    owner = "catppuccin";
    repo = "xcode";
    rev = "e3816a60caaf9889b81866924fd6ef0a4e2ad571";
    hash = "sha256-5g5+bIu4sODwH8PB3tgdcTfmKix/i9LnmTKsR9Sen00=";
  };
in
runCommand "catppuccin-mocha.xccolortheme" { } ''
  substitute "${catppuccin}/themes/Catppuccin Mocha.xccolortheme" "$out" \
    --replace-fail "SFMono-Regular - 14.0" "HackNFM-Regular - 15.0" \
    --replace-fail "SFMono-Medium - 14.0" "HackNFM-Regular - 15.0" \
    --replace-fail "SFMono-Bold - 14.0" "HackNFM-Bold - 15.0" \
    --replace-fail "SFMono-Regular - 10.0" "HackNFM-Regular - 10.0"
''
