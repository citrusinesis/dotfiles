{ pkgs, ... }:

{
  users.users.citrus = {
    isNormalUser = true;
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
