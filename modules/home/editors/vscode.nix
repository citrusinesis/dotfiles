{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;

    mutableExtensionsDir = true;

    profiles.default.userSettings = {
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
      remote.SSH.showLoginTerminal = true;

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
    };

    profiles.default.extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc-icons
      catppuccin.catppuccin-vsc

      jnoortheen.nix-ide
      mkhl.direnv
      arrterian.nix-env-selector

      github.vscode-pull-request-github
      github.vscode-github-actions
      github.copilot

      usernamehw.errorlens
      gruntfuggly.todo-tree

      donjayamanne.githistory
    ];
  };
}
