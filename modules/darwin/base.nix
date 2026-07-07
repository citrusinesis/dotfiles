{
  flake,
  lib,
  pkgs,
  ...
}:

let
  inherit (flake.inputs) self;
  personal = import (self + /personal.nix);
  username = personal.user.username;
in

{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

  system = {
    primaryUser = username;
    stateVersion = 5;
  };

  # nix-darwin's pinned nixos-render-docs invocation (`manual html --toc-depth`)
  # is incompatible with the version shipped by current nixpkgs, which removed
  # --toc-depth in favor of --sidebar-depth. Skip building the HTML manual until
  # nix-darwin updates; man pages (documentation.man) are unaffected.
  documentation.doc.enable = false;

  # darwin-uninstaller embeds a full separate nix-darwin system (built from
  # nix-darwin's own bundled configuration.nix, with documentation.doc.enable
  # defaulting to true) purely to get a darwin-rebuild binary. That inner build
  # hits the same broken nixos-render-docs invocation and can't be fixed via
  # our own documentation settings. Disable the rarely-used uninstaller tool
  # to avoid pulling it in.
  system.tools.darwin-uninstaller.enable = false;

  time.timeZone = personal.timezone;

  networking.knownNetworkServices = lib.mkDefault [
    "Wi-Fi"
    "Ethernet"
  ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  home-manager = {
    backupFileExtension = "bak";
    users.${username} = import (self + /configurations/home/default);
    extraSpecialArgs = { inherit username; };
  };

  environment.systemPackages = with pkgs; [
    coreutils
  ];
}
