{ ... }:

{
  programs.nixvim.keymaps = [
    {
      mode = "i";
      key = "jk";
      action = "<Esc>";
      options.desc = "Exit insert mode";
    }
    {
      mode = "n";
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      options.desc = "Clear search highlight";
    }
    {
      mode = "n";
      key = "<leader>w";
      action = "<cmd>write<CR>";
      options.desc = "Save file";
    }
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>quit<CR>";
      options.desc = "Quit window";
    }
    {
      mode = "n";
      key = "<leader>qQ";
      action = "<cmd>quitall<CR>";
      options.desc = "Quit all";
    }
    {
      mode = "v";
      key = "<";
      action = "<gv";
      options.desc = "Indent left";
    }
    {
      mode = "v";
      key = ">";
      action = ">gv";
      options.desc = "Indent right";
    }
    {
      mode = "v";
      key = "J";
      action = ":m '>+1<CR>gv=gv";
      options.desc = "Move selection down";
    }
    {
      mode = "v";
      key = "K";
      action = ":m '<-2<CR>gv=gv";
      options.desc = "Move selection up";
    }
    {
      mode = "n";
      key = "<C-d>";
      action = "<C-d>zz";
      options.desc = "Scroll down centered";
    }
    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
      options.desc = "Scroll up centered";
    }
    {
      mode = "n";
      key = "n";
      action = "nzzzv";
      options.desc = "Next search result centered";
    }
    {
      mode = "n";
      key = "N";
      action = "Nzzzv";
      options.desc = "Previous search result centered";
    }

    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.desc = "Move to left window";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.desc = "Move to lower window";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.desc = "Move to upper window";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.desc = "Move to right window";
    }
    {
      mode = "n";
      key = "<leader>sh";
      action = "<cmd>split<CR>";
      options.desc = "Split horizontally";
    }
    {
      mode = "n";
      key = "<leader>sv";
      action = "<cmd>vsplit<CR>";
      options.desc = "Split vertically";
    }
    {
      mode = "n";
      key = "<leader>sx";
      action = "<cmd>close<CR>";
      options.desc = "Close split";
    }
    {
      mode = "n";
      key = "<C-Up>";
      action = "<cmd>resize +2<CR>";
      options.desc = "Increase window height";
    }
    {
      mode = "n";
      key = "<C-Down>";
      action = "<cmd>resize -2<CR>";
      options.desc = "Decrease window height";
    }
    {
      mode = "n";
      key = "<C-Left>";
      action = "<cmd>vertical resize -2<CR>";
      options.desc = "Decrease window width";
    }
    {
      mode = "n";
      key = "<C-Right>";
      action = "<cmd>vertical resize +2<CR>";
      options.desc = "Increase window width";
    }

    {
      mode = "n";
      key = "<leader>e";
      action.__raw = ''
        function()
          DotfilesNixvimTabs.toggle_explorer()
        end
      '';
      options.desc = "Toggle explorer";
    }
    {
      mode = "n";
      key = "<leader><space>";
      action.__raw = "function() Snacks.picker.files() end";
      options.desc = "Find files";
    }
    {
      mode = "n";
      key = "<leader>/";
      action.__raw = "function() Snacks.picker.grep() end";
      options.desc = "Grep in files";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action.__raw = "function() Snacks.picker.files() end";
      options.desc = "Find files";
    }
    {
      mode = "n";
      key = "<leader>fF";
      action.__raw = "function() Snacks.picker.git_files() end";
      options.desc = "Find git files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action.__raw = "function() Snacks.picker.grep() end";
      options.desc = "Grep in files";
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>fw";
      action.__raw = "function() Snacks.picker.grep_word() end";
      options.desc = "Grep word or selection";
    }
    {
      mode = "n";
      key = "<leader>fr";
      action.__raw = "function() Snacks.picker.recent() end";
      options.desc = "Recent files";
    }
    {
      mode = "n";
      key = "<leader>fb";
      action.__raw = "function() Snacks.picker.buffers() end";
      options.desc = "Find buffers";
    }
    {
      mode = "n";
      key = "<leader>fh";
      action.__raw = "function() Snacks.picker.help() end";
      options.desc = "Help tags";
    }
    {
      mode = "n";
      key = "<leader>fk";
      action.__raw = "function() Snacks.picker.keymaps() end";
      options.desc = "Keymaps";
    }
    {
      mode = "n";
      key = "<leader>fc";
      action.__raw = "function() Snacks.picker.commands() end";
      options.desc = "Commands";
    }
    {
      mode = "n";
      key = "<leader>fs";
      action.__raw = "function() Snacks.picker.lsp_symbols() end";
      options.desc = "Document symbols";
    }
    {
      mode = "n";
      key = "<leader>fS";
      action.__raw = "function() Snacks.picker.lsp_workspace_symbols() end";
      options.desc = "Workspace symbols";
    }
    {
      mode = "n";
      key = "<leader>fd";
      action.__raw = "function() Snacks.picker.diagnostics_buffer() end";
      options.desc = "Buffer diagnostics";
    }
    {
      mode = "n";
      key = "<leader>fD";
      action.__raw = "function() Snacks.picker.diagnostics() end";
      options.desc = "Workspace diagnostics";
    }

    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>bprevious<CR>";
      options.desc = "Previous buffer";
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>bnext<CR>";
      options.desc = "Next buffer";
    }
    {
      mode = "n";
      key = "<leader>bb";
      action.__raw = "function() Snacks.picker.buffers() end";
      options.desc = "Switch buffer";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>bdelete<CR>";
      options.desc = "Delete buffer";
    }
    {
      mode = "n";
      key = "<leader>bo";
      action.__raw = ''
        function()
          local current = vim.api.nvim_get_current_buf()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if buf ~= current and vim.bo[buf].buflisted then
              pcall(vim.cmd, "bdelete " .. buf)
            end
          end
        end
      '';
      options.desc = "Delete other buffers";
    }

    {
      mode = "n";
      key = "<leader><Tab>n";
      action.__raw = ''
        function()
          DotfilesNixvimTabs.new_tab()
        end
      '';
      options.desc = "New tab";
    }
    {
      mode = "n";
      key = "<leader><Tab>c";
      action.__raw = ''
        function()
          DotfilesNixvimTabs.close_tab()
        end
      '';
      options.desc = "Close tab";
    }
    {
      mode = "n";
      key = "<leader><Tab>h";
      action = "<cmd>tabprevious<CR>";
      options.desc = "Previous tab";
    }
    {
      mode = "n";
      key = "<leader><Tab>l";
      action = "<cmd>tabnext<CR>";
      options.desc = "Next tab";
    }

    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action.__raw = "function() require('flash').jump() end";
      options.desc = "Flash jump";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "S";
      action.__raw = "function() require('flash').treesitter() end";
      options.desc = "Flash treesitter";
    }
    {
      mode = "o";
      key = "r";
      action.__raw = "function() require('flash').remote() end";
      options.desc = "Remote Flash";
    }
    {
      mode = [
        "o"
        "x"
      ];
      key = "R";
      action.__raw = "function() require('flash').treesitter_search() end";
      options.desc = "Flash treesitter search";
    }
    {
      mode = "c";
      key = "<C-s>";
      action.__raw = "function() require('flash').toggle() end";
      options.desc = "Toggle Flash search";
    }

    {
      mode = "n";
      key = "<leader>cv";
      action = "<cmd>VenvSelect<CR>";
      options.desc = "Select Python venv";
    }

    {
      mode = "n";
      key = "[d";
      action.__raw = "function() vim.diagnostic.goto_prev({ float = true }) end";
      options.desc = "Previous diagnostic";
    }
    {
      mode = "n";
      key = "]d";
      action.__raw = "function() vim.diagnostic.goto_next({ float = true }) end";
      options.desc = "Next diagnostic";
    }
    {
      mode = "n";
      key = "<leader>xd";
      action.__raw = "vim.diagnostic.open_float";
      options.desc = "Line diagnostic";
    }
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      options.desc = "Workspace diagnostics";
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      options.desc = "Buffer diagnostics";
    }
    {
      mode = "n";
      key = "<leader>xs";
      action = "<cmd>Trouble symbols toggle focus=false<CR>";
      options.desc = "Document symbols";
    }
    {
      mode = "n";
      key = "<leader>xl";
      action = "<cmd>Trouble lsp toggle focus=false win.position=right<CR>";
      options.desc = "LSP references";
    }
    {
      mode = "n";
      key = "<leader>xq";
      action = "<cmd>Trouble qflist toggle<CR>";
      options.desc = "Quickfix list";
    }
    {
      mode = "n";
      key = "<leader>xL";
      action = "<cmd>Trouble loclist toggle<CR>";
      options.desc = "Location list";
    }
    {
      mode = "n";
      key = "<leader>xt";
      action = "<cmd>TodoTrouble<CR>";
      options.desc = "Todo list";
    }

    {
      mode = "n";
      key = "]h";
      action.__raw = ''
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            require("gitsigns").nav_hunk("next")
          end
        end
      '';
      options.desc = "Next git hunk";
    }
    {
      mode = "n";
      key = "[h";
      action.__raw = ''
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            require("gitsigns").nav_hunk("prev")
          end
        end
      '';
      options.desc = "Previous git hunk";
    }
    {
      mode = "n";
      key = "<leader>gs";
      action.__raw = "function() require('gitsigns').stage_hunk() end";
      options.desc = "Stage hunk";
    }
    {
      mode = "v";
      key = "<leader>gs";
      action.__raw = "function() require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end";
      options.desc = "Stage selected hunk";
    }
    {
      mode = "n";
      key = "<leader>gr";
      action.__raw = "function() require('gitsigns').reset_hunk() end";
      options.desc = "Reset hunk";
    }
    {
      mode = "v";
      key = "<leader>gr";
      action.__raw = "function() require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end";
      options.desc = "Reset selected hunk";
    }
    {
      mode = "n";
      key = "<leader>gS";
      action.__raw = "function() require('gitsigns').stage_buffer() end";
      options.desc = "Stage buffer";
    }
    {
      mode = "n";
      key = "<leader>gu";
      action.__raw = "function() require('gitsigns').undo_stage_hunk() end";
      options.desc = "Undo stage hunk";
    }
    {
      mode = "n";
      key = "<leader>gR";
      action.__raw = "function() require('gitsigns').reset_buffer() end";
      options.desc = "Reset buffer";
    }
    {
      mode = "n";
      key = "<leader>gp";
      action.__raw = "function() require('gitsigns').preview_hunk() end";
      options.desc = "Preview hunk";
    }
    {
      mode = "n";
      key = "<leader>gb";
      action.__raw = "function() require('gitsigns').blame_line({ full = true }) end";
      options.desc = "Blame line";
    }
    {
      mode = "n";
      key = "<leader>gd";
      action.__raw = "function() require('gitsigns').diffthis() end";
      options.desc = "Diff this";
    }
    {
      mode = "n";
      key = "<leader>gD";
      action.__raw = "function() require('gitsigns').diffthis('~') end";
      options.desc = "Diff against previous";
    }

    {
      mode = "n";
      key = "<leader>dc";
      action.__raw = "function() require('dap').continue() end";
      options.desc = "Debug continue";
    }
    {
      mode = "n";
      key = "<leader>db";
      action.__raw = "function() require('dap').toggle_breakpoint() end";
      options.desc = "Toggle breakpoint";
    }
    {
      mode = "n";
      key = "<leader>dB";
      action.__raw = "function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end";
      options.desc = "Conditional breakpoint";
    }
    {
      mode = "n";
      key = "<leader>do";
      action.__raw = "function() require('dap').step_over() end";
      options.desc = "Debug step over";
    }
    {
      mode = "n";
      key = "<leader>di";
      action.__raw = "function() require('dap').step_into() end";
      options.desc = "Debug step into";
    }
    {
      mode = "n";
      key = "<leader>dO";
      action.__raw = "function() require('dap').step_out() end";
      options.desc = "Debug step out";
    }
    {
      mode = "n";
      key = "<leader>du";
      action.__raw = "function() require('dapui').toggle() end";
      options.desc = "Toggle debug UI";
    }
    {
      mode = "n";
      key = "<leader>dr";
      action.__raw = "function() require('dap').repl.toggle() end";
      options.desc = "Toggle debug REPL";
    }
    {
      mode = "n";
      key = "<leader>dl";
      action.__raw = "function() require('dap').run_last() end";
      options.desc = "Run last debug session";
    }
    {
      mode = "n";
      key = "<leader>dx";
      action.__raw = "function() require('dap').terminate() end";
      options.desc = "Stop debug session";
    }

    {
      mode = "n";
      key = "<leader>qs";
      action.__raw = "function() require('persistence').load() end";
      options.desc = "Restore session";
    }
    {
      mode = "n";
      key = "<leader>qS";
      action.__raw = "function() require('persistence').select() end";
      options.desc = "Select session";
    }
    {
      mode = "n";
      key = "<leader>ql";
      action.__raw = "function() require('persistence').load({ last = true }) end";
      options.desc = "Restore last session";
    }
    {
      mode = "n";
      key = "<leader>qd";
      action.__raw = "function() require('persistence').stop() end";
      options.desc = "Stop saving session";
    }

    {
      mode = "n";
      key = "<leader>pm";
      action = "<cmd>MarkdownPreviewToggle<CR>";
      options.desc = "Toggle Markdown preview";
    }
    {
      mode = "n";
      key = "<leader>pt";
      action = "<cmd>TypstPreviewToggle<CR>";
      options.desc = "Toggle Typst preview";
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
}
