{ lib, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--reverse"
      "--border"
      "--info=inline"
    ];
  };

  programs.zsh = {
    plugins = [
      {
        name = "fzf-tab";
        file = "fzf-tab.plugin.zsh";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    # mkOrder 550: after fzf-tab plugin loaded
    initContent = lib.mkOrder 550 ''
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' menu no
      zstyle ':completion:*:*:*:*:files' matcher-list "" "m:{[:lower:][:upper:]}={[:upper:][:lower:]}" "r:|?=**"
      zstyle ':completion:*:*:*:*:directories' matcher-list "" "m:{[:lower:][:upper:]}={[:upper:][:lower:]}" "r:|?=**"
      zstyle ':fzf-tab:*' query-string input
      zstyle ':fzf-tab:*' fzf-flags --scheme=path --tiebreak=index
      zstyle ':fzf-tab:complete:cd:*' fzf-preview '${pkgs.eza}/bin/eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:ls:*' fzf-preview '${pkgs.eza}/bin/eza -1 --color=always $realpath'
      zstyle ':fzf-tab:*' switch-group '<' '>'
    '';
  };
}
