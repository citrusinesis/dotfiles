{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.home;
  nom = lib.getExe pkgs.nix-output-monitor;
in
{
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    MANROFFOPT = "-c";
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
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
      strategy = [
        "history"
        "completion"
      ];
    };
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    siteFunctions.__run_with_nom = ''
      setopt localoptions pipefail
      nix --log-format internal-json -v "$@" |& ${nom} --json
    '';

    shellAliases = {
      lta = "${pkgs.eza}/bin/eza -Ta --level=2";

      sw = ''__run_with_nom run "path:$NH_FLAKE#activate" --'';
      up = ''
        (cd "$NH_FLAKE" &&
          __run_with_nom run ".#update-pinned-packages" &&
          __run_with_nom run ".#update" &&
          __run_with_nom flake check . &&
          __run_with_nom run "path:$NH_FLAKE#activate" --)
      '';
      bump = ''__run_with_nom flake update --flake "$NH_FLAKE"'';
      gc = "nh clean all --keep 5 --keep-since 3d";

      nb = "__run_with_nom build";
      nd = "__run_with_nom develop";
      nr = "__run_with_nom run";
      ns = "__run_with_nom shell";

      df = "df -h";
      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -v";
      cat = "${pkgs.bat}/bin/bat -p";

      grep = "grep --color=auto";

      zshrc = "$EDITOR ~/.zshrc";
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      showFiles = "defaults write com.apple.finder AppleShowAllFiles YES; killall Finder";
      hideFiles = "defaults write com.apple.finder AppleShowAllFiles NO; killall Finder";
    }
    // lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux && cfg.gui.enable) {
      open = "${pkgs.xdg-utils}/bin/xdg-open";
      pbcopy = "${pkgs.xclip}/bin/xclip -selection clipboard";
      pbpaste = "${pkgs.xclip}/bin/xclip -selection clipboard -o";
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
      if [[ -o login && -o interactive && -t 1 && -z ''${SSH_CONNECTION:-} && -z ''${CI:-} ]]; then
        ${pkgs.fastfetch}/bin/fastfetch
      fi

      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        # GUI apps can still find Homebrew, but Nix-provided tools win.
        path=("''${(@)path:#/opt/homebrew/bin}")
        path=("''${(@)path:#/opt/homebrew/sbin}")
        path+=(/opt/homebrew/bin /opt/homebrew/sbin)
      ''}

      if [ -f ~/.zshrc.local ]; then
        source ~/.zshrc.local
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
        file = "sudo.plugin.zsh";
        src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/sudo";
      }
      {
        name = "extract";
        file = "extract.plugin.zsh";
        src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/extract";
      }
    ];
  };
}
