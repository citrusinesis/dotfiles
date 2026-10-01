{
  config,
  lib,
  pkgs,
  ...
}:

let
  settingsPath =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/Code/User/settings.json"
    else
      ".config/Code/User/settings.json";
in
{
  dotfiles.casks = [ "visual-studio-code" ];

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
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.vscode;

    mutableExtensionsDir = true;

    profiles.default.userSettings = {
      "update.mode" = "none";
      "update.showReleaseNotes" = false;
      "extensions.autoCheckUpdates" = true;
      "extensions.autoUpdate" = true;

      "editor.formatOnSaveMode" = "modificationsIfAvailable";
      "editor.formatOnType" = true;

      "editor.smoothScrolling" = true;
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.cursorBlinking" = "smooth";
      "workbench.list.smoothScrolling" = true;
      "terminal.integrated.smoothScrolling" = true;

      "editor.fontFamily" =
        "Hack Nerd Font Mono, GeistMono NF Medium, D2CodingLigature Nerd Font, monospace";
      "editor.fontSize" = 14;
      "terminal.integrated.fontSize" = 14;
      "terminal.integrated.env.linux" = {
        TERM = "xterm-256color";
      };
      "terminal.integrated.env.osx" = {
        TERM = "xterm-256color";
      };

      "editor.formatOnPaste" = true;
      "editor.formatOnSave" = true;

      "terminal.integrated.enableMultiLinePasteWarning" = "auto";

      "workbench.iconTheme" = "catppuccin-mocha";
      "workbench.colorTheme" = "Catppuccin Mocha";
      "catppuccin.accentColor" = config.catppuccin.accent;

      "workbench.sideBar.location" = "right";
      "workbench.activityBar.location" = "top";

      "git.autofetch" = true;

      "remote.SSH.connectTimeout" = 60;
      "remote.SSH.serverInstallTimeout" = 300;

      "github.copilot.enable" = {
        "*" = true;
        plaintext = false;
        markdown = false;
        scminput = false;
      };

      # Nix
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "nix.serverSettings" = {
        nixd = {
          formatting = {
            command = [ "nixfmt" ];
          };
        };
      };
      "nixEnvSelector.useFlakes" = true;

      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "editor.formatOnSave" = true;
      };

      # Rust
      "rust-analyzer.check.command" = "clippy";
      "rust-analyzer.checkOnSave" = true;

      "[rust]" = {
        "editor.defaultFormatter" = "rust-lang.rust-analyzer";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.fixAll" = "explicit";
        };
      };

      "[toml]" = {
        "editor.defaultFormatter" = "tamasfe.even-better-toml";
        "editor.formatOnSave" = true;
      };

      # Go
      "go.useLanguageServer" = true;
      "go.toolsManagement.autoUpdate" = false;
      "go.lintTool" = "golangci-lint";
      "go.lintOnSave" = "package";

      gopls = {
        "formatting.gofumpt" = true;
        "ui.semanticTokens" = true;
        "ui.completion.usePlaceholders" = true;
      };

      "[go]" = {
        "editor.defaultFormatter" = "golang.go";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
        "editor.tabSize" = 4;
        "editor.insertSpaces" = false;
      };

      "[go.mod]" = {
        "editor.defaultFormatter" = "golang.go";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
      };

      # Python
      "python.languageServer" = "None";
      "python.defaultInterpreterPath" = ".venv/bin/python";
      "python.terminal.activateEnvironment" = true;
      "python.testing.pytestEnabled" = true;
      "python.testing.unittestEnabled" = false;
      "basedpyright.analysis.typeCheckingMode" = "strict";
      "basedpyright.analysis.autoImportCompletions" = true;
      "basedpyright.analysis.diagnosticMode" = "workspace";
      "basedpyright.analysis.inlayHints.functionReturnTypes" = true;
      "basedpyright.analysis.inlayHints.variableTypes" = true;

      "[python]" = {
        "editor.defaultFormatter" = "charliermarsh.ruff";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.fixAll.ruff" = "explicit";
          "source.organizeImports.ruff" = "explicit";
        };
        "editor.tabSize" = 4;
      };

      "ruff.organizeImports" = true;
      "ruff.fixAll" = true;
      "ruff.lint.run" = "onSave";
      "ruff.importStrategy" = "fromEnvironment";
    };

  };
}
