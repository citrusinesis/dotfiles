{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    extraLuaConfig = ''
      -- Basic Neovim configuration
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.hlsearch = true
      vim.opt.incsearch = true
      vim.opt.termguicolors = true
      vim.opt.scrolloff = 8
      vim.opt.sidescrolloff = 8
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 300
      vim.opt.clipboard = "unnamedplus"
      vim.opt.undofile = true
      vim.opt.signcolumn = "yes"

      -- Key mappings
      vim.g.mapleader = " "
      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
      
      -- Better navigation in insert mode
      vim.keymap.set("i", "<C-h>", "<Left>")
      vim.keymap.set("i", "<C-j>", "<Down>") 
      vim.keymap.set("i", "<C-k>", "<Up>")
      vim.keymap.set("i", "<C-l>", "<Right>")
    '';

    plugins = with pkgs.vimPlugins; [
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          require('telescope').setup{}
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
          vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        '';
      }

      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require('nvim-treesitter.configs').setup {
            highlight = { enable = true },
            indent = { enable = true },
          }
        '';
      }

      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup {
            options = {
              theme = 'auto',
              component_separators = '|',
              section_separators = { left = "", right = "" },
            },
          }
        '';
      }

      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = ''
          require("nvim-tree").setup{}
          vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
        '';
      }

      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup{}
        '';
      }

     {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          -- Nix LSP
          vim.lsp.config('nil_ls', {})
          vim.lsp.config('nixd', {})
          vim.lsp.enable({'nil_ls', 'nixd'})
          
          -- Global mappings
          vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
          vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

          -- Use LspAttach autocommand to only map the following keys
          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
              local opts = { buffer = ev.buf }
              vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
              vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
              vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
              vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
              vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
              vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
              vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
              vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
              vim.keymap.set('n', '<space>f', function()
                vim.lsp.buf.format { async = true }
              end, opts)
            end,
          })
        '';
      }

      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require'cmp'
          cmp.setup({
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'buffer' },
              { name = 'path' },
            })
          })
        '';
      }

      cmp-nvim-lsp
      cmp-buffer
      cmp-path

      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = ''
          require("catppuccin").setup{}
          vim.cmd.colorscheme "catppuccin"
        '';
      }

      telescope-fzf-native-nvim
      plenary-nvim
      nvim-web-devicons
      which-key-nvim
      comment-nvim
      nvim-autopairs
      indent-blankline-nvim
    ];
  };
}