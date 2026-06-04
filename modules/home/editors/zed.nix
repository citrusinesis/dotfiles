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
      "dockerfile"
      "golangci-lint"

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

      load_direnv = "direct";

      terminal = {
        font_family = "Hack Nerd Font Mono";
        font_size = 14;
      };

      format_on_save = "on";

      inlay_hints = {
        enabled = true;
      };

      languages.Nix.language_servers = [
        "nixd"
        "!nil"
      ];

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
