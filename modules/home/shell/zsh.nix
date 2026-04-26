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
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    MANROFFOPT = "-c";
  }
  // lib.optionalAttrs pkgs.stdenv.isDarwin {
    CLICOLOR = "1";
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
      strategy = [ "completion" ];
    };
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    shellAliases = {
      lta = "${pkgs.eza}/bin/eza -Ta --level=2";

      rb = if pkgs.stdenv.isDarwin then "nh darwin switch" else "nh os switch";
      rbh = "nh home switch";
      up = if pkgs.stdenv.isDarwin then "nh darwin switch --update" else "nh os switch --update";
      bump = "nix flake update --flake $NH_FLAKE";
      gc = "nh clean all --keep 5 --keep-since 3d";

      df = "df -h";
      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -v";
      cat = "${pkgs.bat}/bin/bat -p";

      grep = "grep --color=auto";
      g = "git";
      vi = "nvim";
      vim = "nvim";

      zshrc = "$EDITOR ~/.zshrc";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      expireDuplicatesFirst = true;
      extended = true;
      share = true;
    };

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
        src = pkgs.zsh-nix-shell;
      }
      {
        name = "zsh-abbr";
        file = "zsh-abbr.zsh";
        src = pkgs.zsh-abbr;
      }
      {
        name = "sudo";
        file = "plugins/sudo/sudo.plugin.zsh";
        src = pkgs.oh-my-zsh;
      }
      {
        name = "extract";
        file = "plugins/extract/extract.plugin.zsh";
        src = pkgs.oh-my-zsh;
      }
    ];
  };
}
