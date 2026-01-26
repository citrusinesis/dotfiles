{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  personal = import (self + /personal.nix);
  username = personal.user.username;
in
{
  imports = [
    ./hardware-configuration.nix
    self.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.overlays = [ self.overlays.default ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "blender";
  time.timeZone = personal.timezone;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${username} = import (self + /configurations/home/default);
    extraSpecialArgs = { inherit flake; };
  };

  fonts.fontDir.enable = true;
  fonts.fontDir.decompressFonts = true;
  fonts.fontconfig.defaultFonts = {
    serif = [
      "Noto Serif CJK KR"
      "Noto Serif"
      "Liberation Serif"
    ];
    sansSerif = [
      "Noto Sans CJK KR"
      "Noto Sans"
      "Liberation Sans"
    ];
    monospace = [
      "Hack Nerd Font Mono"
      "GeistMono NF"
      "Liberation Mono"
    ];
    emoji = [ "Noto Color Emoji" ];
  };

  system.stateVersion = "25.11";
}
