{ ... }:

{
  programs.nixvim.plugins.lsp = {
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
}
