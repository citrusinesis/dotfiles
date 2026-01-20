{ pkgs, lib, ... }:

{
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "UTC";

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
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  programs.command-not-found.enable = true;
  programs.bash.completion.enable = true;
  programs.zsh.enable = true;
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
