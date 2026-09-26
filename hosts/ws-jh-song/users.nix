{ pkgs, ... }:
{
  users.groups.jh-song.gid = 11000;
  users.users.jh-song = {
    isNormalUser = true;
    uid = 11000;
    group = "jh-song";
    extraGroups = [
      "wheel"
      "shared"
      "docker"
      "video"
      "render"
    ];
    shell = pkgs.zsh;
    subUidRanges = [
      {
        startUid = 11001;
        count = 54535;
      }
    ];
    subGidRanges = [
      {
        startGid = 11001;
        count = 54535;
      }
    ];
  };
  security.sudo.extraRules = [
    {
      users = [ "jh-song" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
