{ pkgs, ... }:

let
  zedPackage =
    if pkgs.stdenv.isDarwin then
      pkgs.writeShellScriptBin "zed" ''
        exec "/Applications/Zed.app/Contents/Resources/app/bin/zed" "$@"
      ''
    else
      pkgs.zed-editor;
in
{
  programs.zed-editor = {
    enable = true;
    package = zedPackage;

    extensions = [
      "catppuccin"
      "catppuccin-icons"

      "nix"

      "env"
      "toml"
      "just"
      "dockerfile"
      "golangci-lint"
      "biome"

      "opencode"
    ];

    userSettings = {
      theme = "Catppuccin Mocha - No Italics";
      icon_theme = "Catppuccin Mocha";

      buffer_font_family = "Hack Nerd Font Mono";
      buffer_font_fallbacks = [ "D2CodingLigature Nerd Font" ];
      buffer_font_size = 15;
      ui_font_size = 15;
      colorize_brackets = true;

      edit_predictions = {
        provider = "copilot";
      };

      notification_panel = {
        dock = "left";
      };

      project_panel = {
        dock = "right";
      };

      collaboration_panel = {
        dock = "left";
      };

      outline_panel = {
        dock = "right";
      };

      agent = {
        dock = "left";
        favorite_models = [ ];
        model_parameters = [ ];
      };

      git_panel = {
        dock = "right";
        tree_view = true;
      };

      load_direnv = "direct";

      cli_default_open_behavior = "new_window";

      terminal = {
        font_family = "Hack Nerd Font Mono";
        font_fallbacks = [ "D2CodingLigature Nerd Font" ];
        font_size = 14;
      };

      format_on_save = "on";

      inlay_hints = {
        enabled = true;
      };

      languages.Nix = {
        language_servers = [
          "nixd"
          "!nil"
        ];
        formatter.external = {
          command = "nixfmt";
          arguments = [ ];
        };
      };

      lsp.nixd.settings.nixd.formatting.command = [ "nixfmt" ];

      # Python
      languages.Python = {
        language_servers = [
          "basedpyright"
          "ruff"
          "!pyright"
        ];
        formatter.language_server.name = "ruff";
      };

      lsp.basedpyright.settings.basedpyright.analysis = {
        autoSearchPaths = true;
        diagnosticMode = "workspace";
        typeCheckingMode = "strict";
        useLibraryCodeForTypes = true;
      };

      lsp.ruff.initialization_options.settings = {
        organizeImports = true;
        fixAll = true;
      };

      # TypeScript / JavaScript: the TypeScript server owns types and Biome
      # owns diagnostics, imports, and formatting.
      languages.TypeScript = {
        language_servers = [
          "typescript-language-server"
          "biome"
        ];
        formatter.language_server.name = "biome";
      };
      languages.JavaScript = {
        language_servers = [
          "typescript-language-server"
          "biome"
        ];
        formatter.language_server.name = "biome";
      };

      # Go
      languages.Go = {
        language_servers = [
          "gopls"
          "golangci-lint"
        ];

        formatter = [
          { code_action = "source.organizeImports"; }
          "language_server"
        ];
      };

      lsp."golangci-lint".initialization_options = {
        command = [
          "golangci-lint"
          "run"
          "--output.json.path"
          "stdout"
          "--show-stats=false"
          "--output.text.path="
        ];
      };

      lsp.gopls = {
        settings = {
          gofumpt = true;
          staticcheck = true;

          analyses = {
            unusedparams = true;
            shadow = true;
          };
        };

        initialization_options = {
          hints = {
            assignVariableTypes = true;
            compositeLiteralFields = true;
            compositeLiteralTypes = true;
            constantValues = true;
            functionTypeParameters = true;
            parameterNames = true;
            rangeVariableTypes = true;
          };
        };
      };

      # Rust
      languages.Rust = {
        code_actions_on_format = {
          "source.fixAll" = true;
        };
      };

      lsp."rust-analyzer".initialization_options = {
        check = {
          command = "clippy";
        };

        rust = {
          analyzerTargetDir = true;
        };
      };
    };
  };
}
