{ config, pkgs, lib, inputs, username, ... }:

let
  personal = import ../../personal.nix;
in
{
  imports = [
    ../../profiles/darwin-workstation.nix
  ];

  networking.hostName = "squeezer";
  networking.knownNetworkServices = [ "Wi-Fi" "Ethernet" ];
  time.timeZone = personal.timezone;

  homebrew.casks = [
    "google-chrome"
    "firefox"
    "jetbrains-toolbox"
    "visual-studio-code"
    "figma"
    "warp"
    "slack"
    "notion"
    "obsidian"
    "raycast"
    "heynote"
    "tailscale"
  ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };
}
