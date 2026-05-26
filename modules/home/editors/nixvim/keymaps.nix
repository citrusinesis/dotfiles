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
      key = "<leader>e";
      action.__raw = ''
        function()
          DotfilesNixvimTabs.toggle_explorer()
        end
      '';
      options.desc = "File explorer";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action.__raw = "function() Snacks.picker.files() end";
      options.desc = "Find files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action.__raw = "function() Snacks.picker.grep() end";
      options.desc = "Grep in files";
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
      key = "<leader>fr";
      action.__raw = "function() Snacks.picker.recent() end";
      options.desc = "Recent files";
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
      mode = [
        "n"
        "v"
      ];
      key = "<leader>fw";
      action.__raw = "function() Snacks.picker.grep_word() end";
      options.desc = "Grep word under cursor";
    }
    {
      mode = "n";
      key = "<leader>d";
      action.__raw = "vim.diagnostic.open_float";
      options.desc = "Show diagnostic";
    }
    {
      mode = "n";
      key = "<leader>q";
      action.__raw = "vim.diagnostic.setloclist";
      options.desc = "Diagnostic list";
    }
    {
      mode = "n";
      key = "<leader>cf";
      action.__raw = "function() vim.lsp.buf.format({ async = true }) end";
      options.desc = "Format buffer";
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
