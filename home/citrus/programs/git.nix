{ config, lib, pkgs, ... }:

let
  personal = import ../../../personal.nix;
in
{
  programs.git = {
    enable = true;
    userName = personal.git.userName;
    userEmail = personal.git.userEmail;

    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv"
      "result"
      ".vscode"
      ".idea"
      "*.log"
      "*.bak"
      "tmp"
    ];

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "vim";
      color.ui = "auto";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      credential.helper = "cache --timeout=3600";
    };

    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        line-numbers = true;
        syntax-theme = "ansi";
      };
    };
  };
}
