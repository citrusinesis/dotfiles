{
  features,
  lib,
  self,
}:
let
  username = self.darwinConfigurations.juicer.config.system.primaryUser;
  optional = self.darwinConfigurations.juicer.extendModules {
    modules = [
      (features.kitty.resolve { class = "darwin"; })
      (features.vscode.resolve { class = "darwin"; })
      {
        home-manager.users.${username} = {
          imports = [
            (features.kitty.resolve { class = "homeManager"; })
            (features.vscode.resolve { class = "homeManager"; })
          ];
          xdg.configHome = lib.mkForce "/Users/${username}/xdg-config-test";
        };
      }
    ];
  };
  h = optional.config.home-manager.users.${username};
  casks = map (x: x.name) optional.config.homebrew.casks;
in
{
  checks = {
    kitty-settings-only = h.programs.kitty.enable && h.programs.kitty.package == null;
    vscode-settings-only = h.programs.vscode.enable && h.programs.vscode.package == null;
    optional-casks = builtins.elem "kitty" casks && builtins.elem "visual-studio-code" casks;
    custom-xdg-nh = h.programs.nh.flake == "/Users/${username}/xdg-config-test/dotfiles";
  };
  activation = h.home.activationPackage.drvPath;
}
