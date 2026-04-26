{ pkgs, lib, ... }:

{
  networking.networkmanager.enable = lib.mkDefault true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  services.timesyncd.enable = true;

  boot.tmp.cleanOnBoot = true;
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_6_12;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  programs.command-not-found.enable = true;
  programs.bash.completion.enable = true;
  programs.nix-ld.enable = true;

  users.mutableUsers = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    curl
    wget
    htop
    vim
    gnumake
    gcc
    zip
    unzip
  ];
}
