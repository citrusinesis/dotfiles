{ pkgs, ... }:

let
  personal = import ../../../personal.nix;
in
{
  home.packages = with pkgs; [
    gh
  ];

  programs.git = {
    enable = true;

    settings = {
      user = {
        email = personal.git.userEmail;
        name = personal.git.userName;
      };

      alias = {
        a = "add";
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        p = "push";
        l = "log";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "vim";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      credential.helper = "cache --timeout=3600";
    };

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
  };

  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      light = false;
      line-numbers = true;
      syntax-theme = "ansi";
    };
  };
}
