{ ... }:

{
  programs.nixvim.files."after/ftplugin/cpp.lua" = {
    version.enableNixpkgsReleaseCheck = false;
    localOpts = {
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 4;
      expandtab = true;
    };
  };
}
