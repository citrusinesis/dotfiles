{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    extraLuaConfig = ''
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
      vim.opt.mouse = "a"

      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

      vim.keymap.set("i", "<C-h>", "<Left>")
      vim.keymap.set("i", "<C-j>", "<Down>")
      vim.keymap.set("i", "<C-k>", "<Up>")
      vim.keymap.set("i", "<C-l>", "<Right>")
    '';

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      nvim-web-devicons

      {
        plugin = fzf-lua;
        type = "lua";
        config = ''
          local fzf = require('fzf-lua')
          fzf.setup({
            winopts = {
              height = 0.85,
              width = 0.80,
              preview = {
                layout = 'vertical',
                vertical = 'down:45%',
              },
            },
            keymap = {
              fzf = {
                ["ctrl-q"] = "select-all+accept",
              },
            },
          })
          vim.keymap.set('n', '<leader>ff', fzf.files, { desc = 'Find files' })
          vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = 'Grep in files' })
          vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = 'Find buffers' })
          vim.keymap.set('n', '<leader>fh', fzf.help_tags, { desc = 'Help tags' })
          vim.keymap.set('n', '<leader>fr', fzf.oldfiles, { desc = 'Recent files' })
          vim.keymap.set('n', '<leader>fc', fzf.commands, { desc = 'Commands' })
          vim.keymap.set('n', '<leader>fs', fzf.lsp_document_symbols, { desc = 'Document symbols' })
          vim.keymap.set('n', '<leader>fw', fzf.grep_cword, { desc = 'Grep word under cursor' })
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
              theme = 'catppuccin',
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
          vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'File explorer' })
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
          vim.lsp.config('*', {
            capabilities = require('cmp_nvim_lsp').default_capabilities()
          })

          vim.lsp.config('nixd', {})
          vim.lsp.enable('nixd')

          vim.lsp.config('gopls', {})
          vim.lsp.enable('gopls')

          vim.lsp.config('ts_ls', {})
          vim.lsp.enable('ts_ls')

          vim.lsp.config('rust_analyzer', {})
          vim.lsp.enable('rust_analyzer')

          vim.lsp.config('pyright', {})
          vim.lsp.enable('pyright')

          vim.lsp.config('yamlls', {})
          vim.lsp.enable('yamlls')

          vim.lsp.config('jsonls', {})
          vim.lsp.enable('jsonls')

          vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
          vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic list' })

          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
              local function opts(desc)
                return { buffer = ev.buf, desc = desc }
              end
              vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts('Go to declaration'))
              vim.keymap.set('n', '<leader>f', function()
                vim.lsp.buf.format { async = true }
              end, opts('Format buffer'))
            end,
          })
        '';
      }

      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require('cmp')
          cmp.setup({
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
              ['<Tab>'] = cmp.mapping.select_next_item(),
              ['<S-Tab>'] = cmp.mapping.select_prev_item(),
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
          require("catppuccin").setup{ flavour = "mocha" }
          vim.cmd.colorscheme "catppuccin"
        '';
      }

      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          local wk = require("which-key")
          wk.setup{}
          wk.add({
            { "<leader>f", group = "Find" },
            { "<leader>c", group = "Code" },
            { "<leader>r", group = "Refactor" },
            { "g", group = "Go to" },
          })
        '';
      }

      {
        plugin = comment-nvim;
        type = "lua";
        config = ''
          require("Comment").setup{}
        '';
      }

      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require("nvim-autopairs").setup{}
        '';
      }

      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = ''
          require("ibl").setup{}
        '';
      }
    ];
  };
}
