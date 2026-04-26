{
  config,
  lib,
  pkgs,
  ...
}:

let
  settingsPath =
    if pkgs.stdenv.isDarwin then
      "Library/Application Support/Code/User/settings.json"
    else
      ".config/Code/User/settings.json";
in
{
  home.file."${config.home.homeDirectory}/${settingsPath}" = lib.mkIf config.programs.vscode.enable {
    force = true;
  };

  home.activation.vscodeMutableSettings = lib.mkIf config.programs.vscode.enable (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      target="$HOME/${settingsPath}"
      if [ -L "$target" ]; then
        src=$(readlink -f "$target")
        rm "$target"
        install -m 644 "$src" "$target"
      fi
    ''
  );

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

      rust-analyzer.check.command = "clippy";
      rust-analyzer.checkOnSave = true;

      "[rust]" = {
        editor.defaultFormatter = "rust-lang.rust-analyzer";
        editor.formatOnSave = true;
        editor.codeActionsOnSave = {
          "source.fixAll" = "explicit";
        };
      };

      python.languageServer = "Pylance";
      python.analysis.typeCheckingMode = "strict";
      python.analysis.autoImportCompletions = true;
      python.analysis.diagnosticMode = "workspace";
      python.analysis.inlayHints.functionReturnTypes = true;
      python.analysis.inlayHints.variableTypes = true;
      python.defaultInterpreterPath = ".venv/bin/python";
      python.terminal.activateEnvironment = true;
      python.testing.pytestEnabled = true;
      python.testing.unittestEnabled = false;

      "[python]" = {
        editor.defaultFormatter = "ms-python.black-formatter";
        editor.formatOnSave = true;
        editor.codeActionsOnSave = {
          "source.fixAll" = "explicit";
          "source.organizeImports" = "explicit";
        };
        editor.tabSize = 4;
      };

      black-formatter.args = [
        "--line-length"
        "100"
      ];

      ruff.organizeImports = true;
      ruff.fixAll = true;
      ruff.lint.run = "onSave";
      ruff.importStrategy = "fromEnvironment";

      "[toml]" = {
        editor.defaultFormatter = "tamasfe.even-better-toml";
        editor.formatOnSave = true;
      };
    };

    profiles.default.extensions = [
      pkgs.vscode-extensions.mkhl.direnv
    ]
    ++ (with pkgs.vscode-marketplace-release; [
      catppuccin.catppuccin-vsc-icons
      catppuccin.catppuccin-vsc

      github.copilot-chat

      opentofu.vscode-opentofu
      oven.bun-vscode
      myriad-dreamin.tinymist
      nefrob.vscode-just-syntax
    ])
    ++ (with pkgs.vscode-marketplace; [
      jnoortheen.nix-ide
      arrterian.nix-env-selector

      github.vscode-pull-request-github
      github.vscode-github-actions
      anthropic.claude-code
      openai.chatgpt

      usernamehw.errorlens
      gruntfuggly.todo-tree
      donjayamanne.githistory

      rust-lang.rust-analyzer
      dustypomerleau.rust-syntax
      fill-labs.dependi
      tamasfe.even-better-toml

      hashicorp.hcl
      redhat.vscode-yaml
      mineiros.terramate

      ms-azuretools.vscode-containers
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.remote-explorer
      ms-vscode.remote-server

      redis.redis-for-vscode

      ms-python.python
      ms-python.vscode-pylance
      ms-python.debugpy
      ms-python.black-formatter
      charliermarsh.ruff
      ms-toolsai.jupyter

      tomoki1207.pdf
    ]);
  };
}
