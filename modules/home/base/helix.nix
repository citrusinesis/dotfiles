{ pkgs, ... }:
let
  withTypos = servers: servers ++ [ "typos" ];
  # Derive a user-private, per-instance chooser path using Helix's PID ($PPID) without braces that could break %sh{...}.
  yaziChooserInit = ''dir="$XDG_RUNTIME_DIR"; [ -n "$dir" ] || dir="$TMPDIR"; [ -n "$dir" ] || dir=/tmp; chooser="$dir/helix-yazi-chooser-$PPID"'';
  restoreTerminal = [
    '':insert-output printf "\x1b[?1049h\x1b[?2004h" > /dev/tty''
    ":redraw"
    ":set mouse false"
    ":set mouse true"
  ];
in
{
  programs.helix = {
    enable = true;

    extraPackages = with pkgs; [
      golangci-lint-langserver
      markdown-oxide
      marksman
      typos-lsp
    ];

    settings = {
      editor = {
        bufferline = "multiple";
        color-modes = true;
        cursor-shape = {
          insert = "bar";
          select = "underline";
        };
        end-of-line-diagnostics = "hint";
        file-picker.hidden = false;
        indent-guides.render = true;
        inline-diagnostics.cursor-line = "warning";
        lsp.display-inlay-hints = true;
      };

      keys.normal = {
        esc = [
          "collapse_selection"
          "keep_primary_selection"
        ];
        C-y = [
          '':insert-output ${yaziChooserInit}; rm -f "$chooser"; yazi "%{buffer_name}" --chooser-file="$chooser"''
        ]
        ++ restoreTerminal
        ++ [
          '':open %sh{${yaziChooserInit}; if [ -s "$chooser" ]; then cat "$chooser"; else printf '%s\n' "%{buffer_name}"; fi; rm -f "$chooser"}''
        ];
        C-g = [
          ":write-all"
          ":new"
          ":insert-output lazygit"
        ]
        ++ restoreTerminal
        ++ [
          ":buffer-close!"
          ":reload-all"
        ];
      };
    };

    languages = {
      language-server.typos.command = "typos-lsp";
      language-server.clangd.args = [
        "--query-driver=/usr/bin/*,/run/current-system/sw/bin/*,/etc/profiles/per-user/*/bin/*,/nix/store/*/bin/*"
      ];

      language = [
        {
          name = "rust";
          auto-format = true;
          formatter.command = "rustfmt";
          language-servers = withTypos [ "rust-analyzer" ];
        }
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "nixfmt";
            args = [ "-" ];
          };
          language-servers = withTypos [ "nixd" ];
        }
        {
          name = "c";
          auto-format = true;
          language-servers = withTypos [ "clangd" ];
        }
        {
          name = "cpp";
          auto-format = true;
          language-servers = withTypos [ "clangd" ];
        }
        {
          name = "python";
          auto-format = true;
          formatter = {
            command = "ruff";
            args = [
              "format"
              "--line-length"
              "88"
              "-"
            ];
          };
          language-servers = withTypos [
            "basedpyright"
            "ruff"
          ];
        }
        {
          name = "go";
          language-servers = withTypos [
            "gopls"
            "golangci-lint-lsp"
          ];
        }
        {
          name = "markdown";
          language-servers = withTypos [
            "marksman"
            "markdown-oxide"
          ];
        }
      ];
    };
  };
}
