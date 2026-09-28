{
  pkgs,
  lib,
  script,
}:
let
  migration = pkgs.writeText "migrate-key-remapping.sh" (
    lib.replaceStrings [ "/bin/launchctl" "/usr/bin/sw_vers" ] [ "fakeLaunchctl" "fakeSwVers" ] script
  );
in
pkgs.runCommand "key-remapping-migration" { } ''
  bash ${./key-remapping-migration.sh} ${migration}
  touch "$out"
''
