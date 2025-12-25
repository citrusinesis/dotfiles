# Base Darwin system configuration
{ config, pkgs, lib, ... }:

{
  time.timeZone = lib.mkDefault "UTC";

  programs.zsh.enable = true;
  programs.bash.enable = true;

  # System packages (minimal - CLI tools go to home-manager)
  environment.systemPackages = with pkgs; [
    coreutils
  ];

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
}
