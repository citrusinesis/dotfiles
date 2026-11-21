{ pkgs, ... }:

{
  home.packages = [
    (pkgs.teleport_18.override { withRdpClient = false; })
  ];
}
