# Base system configuration (NixOS)
{ config, pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  # Locale
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "UTC";

  # Networking
  networking.networkmanager.enable = lib.mkDefault true;

  # Security
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  # Services
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  services.timesyncd.enable = true;

  # Boot
  boot.tmp.cleanOnBoot = true;
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;

  # Power
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # Programs
  programs.command-not-found.enable = true;
  programs.bash.completion.enable = true;
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  # Users
  users.mutableUsers = lib.mkDefault true;

  # Environment
  environment.shellAliases = {
    ls = "ls --color=auto";
    ll = "ls -la";
    grep = "grep --color=auto";
    g = "git";
    vi = "vim";
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERM = "xterm-256color";
  };

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
