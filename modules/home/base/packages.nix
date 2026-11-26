{ pkgs, ... }:

{
  home.packages = with pkgs; [
    curl
    wget
    jq
    watch
    unzip

    tree
    fastfetch
    entr
    file
    dust
    duf
    procs
    rsync
    ast-grep
    tldr
  ];

  programs.less = {
    enable = true;
    options = {
      RAW-CONTROL-CHARS = true;
      mouse = true;
      wheel-lines = 3;
    };
  };

  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
  };
}
