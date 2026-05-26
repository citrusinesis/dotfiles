{ config, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    nixpkgs.useGlobalPackages = true;

    version.enableNixpkgsReleaseCheck = false;
    impureRtp = false;
    wrapRc = true;

    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
    withPerl = false;

    colorscheme = "catppuccin";
    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;
      expandtab = true;
      ignorecase = true;
      shiftwidth = 2;
      signcolumn = "yes";
      smartcase = true;
      smartindent = true;
      softtabstop = 2;
      splitbelow = true;
      splitright = true;
      tabstop = 2;
      termguicolors = true;
      timeoutlen = 300;
      updatetime = 200;
      wrap = false;
    };

    diagnostic.settings = {
      underline.severity.min.__raw = "vim.diagnostic.severity.WARN";
      virtual_text = {
        spacing = 2;
        source = "if_many";
      };
    };

    files."after/ftplugin/cpp.lua" = {
      version.enableNixpkgsReleaseCheck = false;
      localOpts = {
        tabstop = 4;
        shiftwidth = 4;
        softtabstop = 4;
        expandtab = true;
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      nvim-osc52
    ];

    extraPackages = with pkgs; [
      fd
      git
      nixfmt
      ripgrep
      shellcheck
      shfmt
      stylua
    ];

    plugins = {
      blink-cmp = {
        enable = true;
        setupLspCapabilities = true;
        settings = {
          keymap.preset = "default";
          appearance.nerd_font_variant = "mono";
          completion.documentation.auto_show = true;
          signature.enabled = true;
        };
      };

      bufferline.enable = true;
      crates = {
        enable = true;
        settings = {
          completion.crates.enabled = true;
          lsp = {
            enabled = true;
            actions = true;
            completion = true;
            hover = true;
          };
        };
      };

      dap.enable = true;
      dap-ui.enable = true;
      dap-virtual-text.enable = true;

      flash.enable = true;
      gitsigns.enable = true;
      lazydev.enable = true;

      lsp = {
        enable = true;
        inlayHints = true;
        keymaps = {
          silent = true;
          diagnostic = {
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
          lspBuf = {
            K = "hover";
            gD = "declaration";
            gd = "definition";
            gi = "implementation";
            gr = "references";
            "<leader>cr" = "rename";
          };
          extra = [
            {
              mode = [
                "n"
                "v"
              ];
              key = "<leader>ca";
              action.__raw = "vim.lsp.buf.code_action";
              options.desc = "Code Action";
            }
            {
              key = "<leader>co";
              action.__raw = ''
                function()
                  vim.lsp.buf.code_action({
                    apply = true,
                    context = {
                      only = { "source.organizeImports" },
                      diagnostics = {},
                    },
                  })
                end
              '';
              options.desc = "Organize Imports";
            }
          ];
        };
        onAttach = ''
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        '';
        servers = {
          basedpyright = {
            enable = true;
            settings = {
              basedpyright.analysis = {
                autoSearchPaths = true;
                diagnosticMode = "openFilesOnly";
                typeCheckingMode = "basic";
                useLibraryCodeForTypes = true;
              };
            };
          };
          jsonls.enable = true;
          lua_ls = {
            enable = true;
            settings = {
              diagnostics.globals = [ "vim" ];
              telemetry.enable = false;
              workspace.checkThirdParty = false;
            };
          };
          marksman.enable = true;
          nil_ls.enable = true;
          ruff = {
            enable = true;
            extraOptions = {
              cmd_env.RUFF_TRACE = "messages";
              init_options.settings.logLevel = "error";
            };
          };
          taplo.enable = true;
          texlab.enable = true;
          tinymist.enable = true;
          ts_ls.enable = true;
          yamlls.enable = true;
        };
      };

      lualine.enable = true;
      markdown-preview.enable = true;
      mini-ai.enable = true;
      mini-icons.enable = true;
      mini-pairs.enable = true;
      noice.enable = true;
      notify.enable = true;
      nui.enable = true;
      persistence.enable = true;
      render-markdown.enable = true;
      schemastore.enable = true;

      rustaceanvim = {
        enable = true;
        settings = {
          dap.adapter = {
            type = "executable";
            name = "lldb";
            command = "${pkgs.lldb}/bin/lldb-dap";
          };
          server = {
            on_attach.__raw = ''
              function(_, bufnr)
                vim.keymap.set("n", "<leader>cR", function()
                  vim.cmd.RustLsp("codeAction")
                end, { desc = "Code Action", buffer = bufnr })

                vim.keymap.set("n", "<leader>dr", function()
                  vim.cmd.RustLsp("debuggables")
                end, { desc = "Rust Debuggables", buffer = bufnr })
              end
            '';
            default_settings."rust-analyzer" = {
              cargo = {
                allFeatures = true;
                loadOutDirsFromCheck = true;
                buildScripts.enable = true;
              };
              checkOnSave = true;
              diagnostics.enable = true;
              procMacro = {
                enable = true;
                ignored = {
                  async-trait = [ "async_trait" ];
                  napi-derive = [ "napi" ];
                  async-recursion = [ "async_recursion" ];
                };
              };
              files.excludeDirs = [
                ".direnv"
                ".git"
                ".github"
                ".gitlab"
                "bin"
                "node_modules"
                "target"
                "venv"
                ".venv"
              ];
            };
          };
        };
      };

      snacks = {
        enable = true;
        settings = {
          bigfile.enabled = true;
          dashboard.enabled = true;
          explorer.enabled = true;
          image = { };
          indent.enabled = true;
          input.enabled = true;
          notifier.enabled = true;
          picker.enabled = true;
          quickfile.enabled = true;
          scope.enabled = true;
          scroll.enabled = true;
          statuscolumn.enabled = true;
          words.enabled = true;
        };
      };

      todo-comments.enable = true;
      treesitter = {
        enable = true;
        folding.enable = true;
        highlight.enable = true;
        indent.enable = true;
        grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
          bash
          c
          cpp
          diff
          html
          javascript
          jsdoc
          json
          latex
          lua
          luadoc
          luap
          markdown
          markdown_inline
          ninja
          nix
          python
          query
          regex
          ron
          rst
          rust
          toml
          tsx
          typst
          typescript
          vim
          vimdoc
          yaml
        ];
      };
      treesitter-textobjects.enable = true;
      trouble.enable = true;
      ts-autotag.enable = true;
      typst-preview.enable = true;
      typst-vim.enable = true;
      venv-selector = {
        enable = true;
        settings.name = [
          ".venv"
          "venv"
        ];
      };
      vimtex = {
        enable = true;
        texlivePackage = null;
        settings.view_method = "general";
      };
      web-devicons.enable = true;
      which-key.enable = true;
    };

    keymaps = [
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
        options.desc = "Exit insert mode";
      }
      {
        mode = "n";
        key = "<leader>y";
        action.__raw = ''require("osc52").copy_operator'';
        options = {
          desc = "Copy OSC52";
          expr = true;
        };
      }
      {
        mode = "n";
        key = "<leader>yy";
        action = "<leader>y_";
        options = {
          desc = "Copy line OSC52";
          remap = true;
        };
      }
      {
        mode = "v";
        key = "<leader>y";
        action.__raw = ''require("osc52").copy_visual'';
        options.desc = "Copy OSC52";
      }
    ];
  };
}
