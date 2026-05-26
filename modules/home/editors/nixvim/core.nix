{ ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    nixpkgs.useGlobalPackages = true;

    version.enableNixpkgsReleaseCheck = false;
    impureRtp = false;
    wrapRc = true;

    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
    withPerl = false;

    colorscheme = "catppuccin";
    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;
      expandtab = true;
      foldlevel = 99;
      foldlevelstart = 99;
      ignorecase = true;
      shiftwidth = 2;
      signcolumn = "yes";
      smartcase = true;
      smartindent = true;
      softtabstop = 2;
      splitbelow = true;
      splitright = true;
      tabstop = 2;
      termguicolors = true;
      timeoutlen = 300;
      updatetime = 200;
      wrap = false;
    };

    diagnostic.settings = {
      underline.severity.min.__raw = "vim.diagnostic.severity.WARN";
      virtual_text = {
        spacing = 2;
        source = "if_many";
      };
    };
  };
}
