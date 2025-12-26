{ username, ... }:

let
  personal = import ../../personal.nix;
in
{
  imports = [
    ../../profiles/darwin-workstation.nix
    ./applications.nix
  ];

  networking.hostName = "squeezer";
  networking.knownNetworkServices = [ "Wi-Fi" "Ethernet" ];
  time.timeZone = personal.timezone;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };
}
