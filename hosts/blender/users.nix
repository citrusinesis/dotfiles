{ pkgs, ... }:
{
  users.users.citrus = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };
  security.sudo.extraRules = [
    {
      users = [ "citrus" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
