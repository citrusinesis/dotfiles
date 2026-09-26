{ lib, pkgs, ... }:
let
  hidutilKeyMapping = builtins.toJSON {
    UserKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771129; # 0x700000039 — Caps Lock
        HIDKeyboardModifierMappingDst = 30064771181; # 0x70000006D — F18
      }
    ];
  };
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home.activation.migrateLegacyKeyRemapping =
      lib.hm.dag.entryBetween [ "setupLaunchAgents" ] [ "writeBoundary" ]
        (builtins.readFile ./migrate-key-remapping.sh);

    launchd.agents.key-remapping = {
      enable = true;
      config = {
        Label = "com.local.KeyRemapping";
        ProgramArguments = [
          "/usr/bin/hidutil"
          "property"
          "--set"
          hidutilKeyMapping
        ];
        RunAtLoad = true;
      };
    };
  };
}
