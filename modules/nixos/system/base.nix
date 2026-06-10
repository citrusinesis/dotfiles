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

  # nix-index (home-manager) provides command-not-found handling; the builtin
  # implementation needs a channel database that flake systems do not have.
  programs.command-not-found.enable = false;
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
