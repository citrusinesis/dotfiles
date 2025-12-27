{ config, lib, pkgs, ... }:

{
  home.sessionPath = [
    "$HOME/.local/bin"
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  home.sessionVariables = lib.mkIf pkgs.stdenv.isDarwin {
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

      la = "ls -lah";
      l = "ls -CF";

      update =
        if pkgs.stdenv.isDarwin
        then "sudo darwin-rebuild switch --flake ~/.config/dotfiles#squeezer"
        else "sudo nixos-rebuild switch --flake ~/.config/dotfiles#blender";

      upgrade =
        if pkgs.stdenv.isDarwin
        then "nix flake update --flake ~/.config/dotfiles && sudo darwin-rebuild switch --flake ~/.config/dotfiles#squeezer"
        else "nix flake update --flake ~/.config/dotfiles && sudo nixos-rebuild switch --flake ~/.config/dotfiles#blender";

      kubectl = "minikube kubectl --";

      df = "df -h";
      free = "free -m";
      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -v";
      cat = "${pkgs.bat}/bin/bat";

      zshrc = "$EDITOR ~/.zshrc";
      dotfiles = "cd ~/.config/dotfiles";
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
      theme = "";
    };

    initContent = lib.mkOrder 550 ''
      ${pkgs.fastfetch}/bin/fastfetch

      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      if [ -n "''${commands[fzf-share]}" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi

      if command -v minikube &> /dev/null; then
        source <(minikube completion zsh)
      fi

      if command -v helm &> /dev/null; then
        source <(helm completion zsh)
      fi

      if command -v minikube &> /dev/null && [ "$(minikube status -o json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.Host // "Stopped"')" = "Running" ]; then
        source <(minikube kubectl -- completion zsh)
        if [ "$(minikube config get driver 2>/dev/null)" = "docker" ]; then
          eval $(minikube -p minikube docker-env)
        fi
      fi

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
