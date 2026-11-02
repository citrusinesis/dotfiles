{ pkgs, ... }:

{
  users.users.citrus = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "render"
      "docker"
    ];
    shell = pkgs.zsh;
  };
}
