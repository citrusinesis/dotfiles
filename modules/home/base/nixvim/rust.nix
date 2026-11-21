{ pkgs, ... }:

{
  programs.nixvim.plugins = {
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
              end, { desc = "Rust code action", buffer = bufnr })

              vim.keymap.set("n", "<leader>drd", function()
                vim.cmd.RustLsp("debuggables")
              end, { desc = "Rust debuggables", buffer = bufnr })
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
  };
}
