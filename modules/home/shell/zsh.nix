{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.sessionPath = [
    "$HOME/.local/bin"
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERM = "xterm-256color";
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    CLICOLOR = "1";
  };

  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
      strategy = [ "completion" ];
    };
    syntaxHighlighting.enable = true;

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      ls = "${pkgs.eza}/bin/eza --icons --group-directories-first";
      l = "${pkgs.eza}/bin/eza -l --icons --group-directories-first --git";
      la = "${pkgs.eza}/bin/eza -la --icons --group-directories-first --git";
      ll = "${pkgs.eza}/bin/eza -l --icons --group-directories-first --git --header";
      lt = "${pkgs.eza}/bin/eza -T --icons --group-directories-first --level=2";
      lta = "${pkgs.eza}/bin/eza -Ta --icons --group-directories-first --level=2";

      update = "git -C \${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles add -A && nix run \${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles#activate";
      upgrade = "git -C \${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles add -A && nix run \${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles#update && nix run \${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles#activate";

      df = "df -h";
      free = "free -m";
      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -v";
      cat = "${pkgs.bat}/bin/bat";

      grep = "grep --color=auto";
      g = "git";
      vi = "nvim";
      vim = "nvim";

      zshrc = "$EDITOR ~/.zshrc";
      dotfiles = "cd \${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      expireDuplicatesFirst = true;
      extended = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "npm"
        "yarn"
        "sudo"
        "command-not-found"
        "colored-man-pages"
        "extract"
      ];
      theme = ""; # using starship
    };

    # mkOrder 550: after plugins loaded
    initContent = lib.mkOrder 550 ''
      ${pkgs.fastfetch}/bin/fastfetch

      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      nix() {
        case "$1" in
          build|run|flake)
            command nix "$@" --log-format internal-json -v |& ${pkgs.nix-output-monitor}/bin/nom --json
            ;;
          shell|develop)
            ${pkgs.nix-output-monitor}/bin/nom "$@"
            ;;
          *)
            command nix "$@"
            ;;
        esac
      }

      if [ -f ~/.zshrc.local ]; then
        source ~/.zshrc.local
      fi

      if [[ "$(uname)" == "Darwin" ]]; then
        alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
        alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
      else
        alias open='xdg-open'
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
      fi
    '';

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];
  };

}
