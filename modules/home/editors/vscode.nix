{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    mutableExtensionsDir = false;

    profiles.default.userSettings = {
      update.mode = "none";
      update.showReleaseNotes = false;
      extensions.autoCheckUpdates = false;
      extensions.autoUpdate = false;

      editor.formatOnSaveMode = "modificationsIfAvailable";
      editor.formatOnType = true;

      editor.smoothScrolling = true;
      editor.cursorSmoothCaretAnimation = "on";
      editor.cursorBlinking = "smooth";
      workbench.list.smoothScrolling = true;
      terminal.integrated.smoothScrolling = true;

      editor.fontFamily = "Hack Nerd Font Mono, GeistMono NF Medium, D2CodingLigature Nerd Font, monospace";
      editor.fontSize = 15;
      terminal.integrated.fontSize = 14;

      editor.formatOnPaste = true;
      editor.formatOnSave = true;

      terminal.integrated.enableMultiLinePasteWarning = "never";

      workbench.iconTheme = "catppuccin-mocha";
      workbench.colorTheme = "Catppuccin Mocha";

      workbench.sideBar.location = "right";
      workbench.activityBar.location = "top";

      git.autofetch = true;

      remote.SSH.connectTimeout = 60;
      remote.SSH.serverInstallTimeout = 300;

      nix.serverPath = "nixd";
      nix.serverSettings = {
        nil = {
          formatting = {
            command = [ "nixfmt" ];
          };
          nix = {
            flake = {
              nixpkgsInputName = "nixpkgs";
            };
          };
        };
      };
      nix.enableLanguageServer = true;
      nixEnvSelector.useFlakes = true;

      github.copilot.enable = {
        "*" = true;
        plaintext = false;
        markdown = false;
        scminput = false;
      };

      claudeCode.useTerminal = true;

      rust-analyzer.check.command = "clippy";
      rust-analyzer.checkOnSave = true;

      "[rust]" = {
        editor.defaultFormatter = "rust-lang.rust-analyzer";
        editor.formatOnSave = true;
        editor.codeActionsOnSave = {
          "source.fixAll" = "explicit";
        };
      };
    };

    profiles.default.extensions =
      (with pkgs.vscode-extensions; [
        catppuccin.catppuccin-vsc-icons
        catppuccin.catppuccin-vsc

        jnoortheen.nix-ide
        mkhl.direnv
        arrterian.nix-env-selector

        github.vscode-pull-request-github
        github.vscode-github-actions
        github.copilot
        github.copilot-chat

        anthropic.claude-code

        usernamehw.errorlens
        gruntfuggly.todo-tree
        donjayamanne.githistory

        rust-lang.rust-analyzer
        fill-labs.dependi
        tamasfe.even-better-toml

        hashicorp.hcl
        redhat.vscode-yaml

        ms-azuretools.vscode-containers
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-vscode.remote-explorer

        myriad-dreamin.tinymist
        nefrob.vscode-just-syntax
        tomoki1207.pdf
      ])
      ++ (with pkgs.vscode-marketplace; [
        dustypomerleau.rust-syntax
        mineiros.terramate
        ms-vscode.remote-server
        openai.chatgpt
        opentofu.vscode-opentofu
        oven.bun-vscode
        redis.redis-for-vscode
      ]);
  };
}
