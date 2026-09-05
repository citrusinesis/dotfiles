{
  lib,
  self,
  system,
}:
let
  isDarwin = system == "aarch64-darwin";
  configurations = if isDarwin then self.darwinConfigurations else self.nixosConfigurations;
  sort = lib.sort builtins.lessThan;
  commonCasks = [
    "helium-browser"
    "spotify"
    "slack"
    "raycast"
    "claude"
    "chatgpt"
    "linear"
    "tailscale-app"
    "logi-options+"
    "element"
    "ghostty"
    "monitorcontrol"
    "obsidian"
    "zed"
    "winbox"
  ];
  extraCasks = {
    juicer = [
      "notion"
      "cloudflare-warp"
      "lm-studio"
      "utm"
    ];
    mixer = [ "mongodb-compass" ];
  };
  desktopPackages = [
    "element-desktop"
    "ghostty-bin"
    "ghostty"
    "monitorcontrol"
    "obsidian"
    "zed-editor"
    "winbox"
    "lmstudio"
    "utm"
    "mongodb-compass"
    "kitty"
    "vscode"
  ];
  hostChecks =
    name: configuration:
    let
      c = configuration.config;
      username = if name == "ws-jh-song" then "jh-song" else "citrus";
      h = c.home-manager.users.${username};
      packages = map lib.getName h.home.packages;
      primaryDesktop =
        p: builtins.elem (lib.getName p) desktopPackages && (p.outputName or "out") == "out";
    in
    {
      "${name}/identity" =
        c.dotfiles.primaryUser == username
        && c.networking.hostName == name
        && c.nixpkgs.hostPlatform.system == system
        && h.home.username == username
        && h.home.homeDirectory == (if isDarwin then "/Users/${username}" else "/home/${username}");
      "${name}/state-versions" =
        c.system.stateVersion == (if isDarwin then 5 else "25.11") && h.home.stateVersion == "25.11";
      "${name}/embedded-home" =
        c.home-manager.useGlobalPkgs
        && c.home-manager.useUserPackages
        && c.home-manager.backupCommand != null;
      "${name}/developer-profile" =
        h.programs.nixvim.enable
        && h.programs.zsh.enable
        && h.programs.git.enable
        && h.programs.direnv.enable
        && h.programs.gpg.enable;
      "${name}/nh" =
        h.programs.nh.enable
        && !h.programs.nh.clean.enable
        && h.programs.nh.flake == "${h.xdg.configHome}/dotfiles"
        && h.home.sessionVariables.NH_FLAKE == h.programs.nh.flake;
      "${name}/no-legacy-aliases" =
        lib.all (alias: !(builtins.hasAttr alias h.programs.zsh.shellAliases)) [
          "sw"
          "up"
          "bump"
          "gc"
        ]
        && !(h.programs.zsh.siteFunctions ? __nix_run_with_nom);
      "${name}/optional-features-off" =
        !h.programs.kitty.enable
        && !h.programs.vscode.enable
        && !(h.dotfiles.home.podman.enable or false)
        && !(builtins.elem "podman" packages);
      "${name}/workstation-selection" = h.programs.zed-editor.enable == isDarwin;
      "${name}/apple-container" = (h.dotfiles.home.appleContainer.enable or false) == isDarwin;
      "${name}/gui-apps-not-installed-by-nix" =
        !lib.any primaryDesktop (h.home.packages ++ c.environment.systemPackages);
      "${name}/gpg-helper" =
        lib.getName h.services.gpg-agent.pinentry.package
        == (if isDarwin then "pinentry-mac" else "pinentry-curses");
      "${name}/nix-policy" =
        lib.getName c.nix.package == "lix"
        && c.nix.gc.automatic
        && c.nix.gc.options == "--delete-older-than 14d"
        &&
          c.nix.settings.trusted-users == [
            "root"
            username
          ];
    }
    // lib.optionalAttrs isDarwin {
      "${name}/casks" =
        sort (map (x: x.name) c.homebrew.casks) == sort (commonCasks ++ extraCasks.${name});
      "${name}/mas" =
        c.homebrew.masApps == {
          KakaoTalk = 869223134;
          "RunCat Neo" = 6757801838;
        };
      "${name}/brew-policy" =
        c.homebrew.enable
        && !c.homebrew.onActivation.autoUpdate
        && !c.homebrew.onActivation.upgrade
        && c.homebrew.onActivation.cleanup == "zap";
      "${name}/settings-only" =
        h.programs.zed-editor.package == null
        && !h.targets.darwin.linkApps.enable
        && !h.targets.darwin.copyApps.enable;
      "${name}/ghostty-path-and-terminfo" =
        builtins.elem "/Applications/Ghostty.app/Contents/MacOS" h.home.sessionPath
        && h.home.file ? ".terminfo";
    };
in
lib.foldl' (checks: name: checks // hostChecks name configurations.${name}) {
  darwin-host-set =
    builtins.attrNames self.darwinConfigurations == [
      "juicer"
      "mixer"
    ];
  nixos-host-set =
    builtins.attrNames self.nixosConfigurations == [
      "blender"
      "ws-jh-song"
    ];
  private-aspects =
    !(self ? aspects)
    && !(self ? modules)
    && !(self ? homeModules)
    && !(self ? darwinModules)
    && (self.nixosModules or { }) == { };
  no-home-only =
    !(self ? homeConfigurations) && !(self.legacyPackages.${system} ? homeConfigurations);
  no-activation-wrappers =
    lib.all
      (
        name:
        !(builtins.hasAttr name self.packages.${system}) && !(builtins.hasAttr name self.apps.${system})
      )
      [
        "activate"
        "update"
        "default"
      ];
  pinned-nh = self.packages.${system} ? nh;
  local-updater = self.apps.${system} ? update-pinned-packages;
} (builtins.attrNames configurations)
