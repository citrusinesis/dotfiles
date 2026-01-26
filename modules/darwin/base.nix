{
  pkgs,
  lib,
  ...
}:

{
  time.timeZone = lib.mkDefault "UTC";

  programs.zsh.enable = true;
  programs.bash.enable = true;

  environment.systemPackages = with pkgs; [
    coreutils
  ];
}
