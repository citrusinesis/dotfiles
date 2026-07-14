{ ... }:

{
  programs.nixvim.plugins.lsp = {
    enable = true;
    inlayHints = true;
    onAttach = ''
      if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
      end
      if client.name == "ts_ls" then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
      end

      map("n", "K", vim.lsp.buf.hover, "Hover documentation")
      map("n", "gd", vim.lsp.buf.definition, "Go to definition")
      map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
      map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
      map("n", "gr", vim.lsp.buf.references, "References")
      map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
      map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
      map("n", "<leader>cf", function()
        vim.lsp.buf.format({ async = true })
      end, "Format buffer")
      map("n", "<leader>co", function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.organizeImports" },
            diagnostics = {},
          },
        })
      end, "Organize imports")
      map("n", "<leader>cl", function()
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        local names = {}
        for _, active_client in ipairs(clients) do
          table.insert(names, active_client.name)
        end
        vim.notify(#names == 0 and "No active LSP clients" or "LSP clients: " .. table.concat(names, ", "))
      end, "Show LSP clients")
    '';
    servers = {
      biome.enable = true;
      basedpyright = {
        enable = true;
        settings = {
          basedpyright.analysis = {
            autoSearchPaths = true;
            diagnosticMode = "workspace";
            typeCheckingMode = "strict";
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
      nixd = {
        enable = true;
        settings.nixd.formatting.command = [ "nixfmt" ];
      };
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
}
