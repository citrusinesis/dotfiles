{ ... }:

{
  programs.nixvim.plugins.lsp = {
    enable = true;
    inlayHints = true;
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
