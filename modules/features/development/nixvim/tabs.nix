{ ... }:

{
  programs.nixvim = {
    files."after/plugin/dotfiles-tabs.lua".extraConfigLua = ''
      DotfilesNixvimTabs = DotfilesNixvimTabs or {}

      local tabs = DotfilesNixvimTabs

      local function snacks()
        local snacks_mod = rawget(_G, "Snacks")
        if snacks_mod then
          return snacks_mod
        end

        local ok, module = pcall(require, "snacks")
        if ok then
          return module
        end
      end

      function tabs.current_tab_has_explorer()
        local snacks_mod = snacks()
        if not snacks_mod or not snacks_mod.picker then
          return false
        end

        return #snacks_mod.picker.get({ source = "explorer" }) > 0
      end

      function tabs.ensure_explorer()
        if not vim.g.dotfiles_snacks_explorer_persistent then
          return
        end

        vim.schedule(function()
          if not vim.g.dotfiles_snacks_explorer_persistent then
            return
          end

          local snacks_mod = snacks()
          if not snacks_mod or not snacks_mod.picker or not snacks_mod.explorer then
            return
          end

          if tabs.current_tab_has_explorer() then
            return
          end

          local win = vim.api.nvim_get_current_win()
          local buftype = vim.bo[vim.api.nvim_get_current_buf()].buftype
          if buftype ~= "" and buftype ~= "acwrite" then
            return
          end

          snacks_mod.explorer()
          if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_set_current_win, win)
          end
        end)
      end

      function tabs.toggle_explorer()
        local snacks_mod = snacks()
        if not snacks_mod or not snacks_mod.explorer then
          return
        end

        vim.g.dotfiles_snacks_explorer_persistent = not tabs.current_tab_has_explorer()
        snacks_mod.explorer()
      end

      function tabs.new_tab()
        vim.cmd("tabnew")
        tabs.ensure_explorer()
      end

      function tabs.close_tab()
        local total = vim.fn.tabpagenr("$")
        if total <= 1 then
          vim.cmd("quit")
          return
        end

        local current = vim.fn.tabpagenr()
        local ok, err = pcall(vim.cmd, "tabclose")
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
          return
        end

        if current <= vim.fn.tabpagenr("$") then
          pcall(vim.cmd, "tabnext " .. current)
        end

        tabs.ensure_explorer()
      end

      vim.api.nvim_create_autocmd("TabEnter", {
        group = vim.api.nvim_create_augroup("dotfiles_nixvim_tabs", { clear = true }),
        callback = function()
          tabs.ensure_explorer()
        end,
      })
    '';

  };
}
