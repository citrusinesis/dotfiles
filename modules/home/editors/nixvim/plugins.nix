{ pkgs, ... }:

{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      nvim-osc52
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
      dap.enable = true;
      dap-ui.enable = true;
      dap-virtual-text.enable = true;
      flash.enable = true;
      gitsigns.enable = true;
      lazydev.enable = true;
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
      todo-comments.enable = true;
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
  };
}
