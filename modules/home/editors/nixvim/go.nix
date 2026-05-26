{ pkgs, ... }:

{
  programs.nixvim = {
    files."after/ftplugin/go.lua" = {
      version.enableNixpkgsReleaseCheck = false;
      localOpts = {
        tabstop = 4;
        shiftwidth = 4;
        softtabstop = 4;
        expandtab = false;
      };
    };

    files."after/ftplugin/gomod.lua" = {
      version.enableNixpkgsReleaseCheck = false;
      localOpts = {
        tabstop = 4;
        shiftwidth = 4;
        softtabstop = 4;
        expandtab = false;
      };
    };

    files."after/ftplugin/gowork.lua" = {
      version.enableNixpkgsReleaseCheck = false;
      localOpts = {
        tabstop = 4;
        shiftwidth = 4;
        softtabstop = 4;
        expandtab = false;
      };
    };

    autoGroups.nixvim_go.clear = true;
    autoCmd = [
      {
        event = "BufWritePre";
        pattern = "*.go";
        group = "nixvim_go";
        desc = "Organize Go imports and format";
        callback.__raw = ''
          function(args)
            local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "gopls" })
            local client = clients[1]
            if client == nil then
              return
            end

            local encoding = client.offset_encoding or "utf-16"
            local params = vim.lsp.util.make_range_params(0, encoding)
            params.context = {
              only = { "source.organizeImports" },
              diagnostics = {},
            }

            local result = vim.lsp.buf_request_sync(args.buf, "textDocument/codeAction", params, 1000)
            for _, response in pairs(result or {}) do
              for _, action in pairs(response.result or {}) do
                if action.edit then
                  vim.lsp.util.apply_workspace_edit(action.edit, encoding)
                end
                if action.command then
                  vim.lsp.buf.execute_command(action.command)
                end
              end
            end

            vim.lsp.buf.format({ bufnr = args.buf, async = false, timeout_ms = 3000 })
          end
        '';
      }
    ];

    plugins = {
      dap-go = {
        enable = true;
        settings.delve = {
          path = "${pkgs.delve}/bin/dlv";
          initialize_timeout_sec = 20;
          port = "\${port}";
        };
      };

      lsp.servers.gopls = {
        enable = true;
        settings = {
          gofumpt = true;
          semanticTokens = true;
          staticcheck = true;
          usePlaceholders = true;
          completeUnimported = true;
          directoryFilters = [
            "-.direnv"
            "-.git"
            "-node_modules"
            "-target"
            "-venv"
            "-.venv"
          ];
          analyses = {
            nilness = true;
            unusedparams = true;
            unusedwrite = true;
            useany = true;
          };
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
        onAttach.function = ''
          vim.keymap.set("n", "<leader>dgc", function()
            require("dap").continue()
          end, { desc = "Go debug continue", buffer = bufnr })

          vim.keymap.set("n", "<leader>dgt", function()
            require("dap-go").debug_test()
          end, { desc = "Go debug test", buffer = bufnr })

          vim.keymap.set("n", "<leader>dgT", function()
            require("dap-go").debug_last_test()
          end, { desc = "Go debug last test", buffer = bufnr })
        '';
      };
    };
  };
}
