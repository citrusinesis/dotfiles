{
  lib,
  self,
  system,
  hosts,
}:
let
  isDarwin = system == "aarch64-darwin";
  configurations = if isDarwin then self.darwinConfigurations else self.nixosConfigurations;
  hostsOn = suffix: builtins.attrNames (lib.filterAttrs (_: h: lib.hasSuffix suffix h.system) hosts);
  ownsNoPreferences =
    h:
    lib.all
      (
        domains:
        lib.all (domain: lib.all (value: value == null) (builtins.attrValues domain)) (
          builtins.attrValues domains
        )
      )
      [
        h.targets.darwin.defaults
        h.targets.darwin.currentHostDefaults
      ]
    && !(h.home.activation ? setDarwinDefaults)
    && !(h.home.activation ? restartDock);
  sort = lib.sort builtins.lessThan;
  # HM supplies its standalone CLI, profile-specific session variables, and
  # NixOS font-cache placeholders through its integration adapters.
  applicationPackages =
    packages:
    sort (
      map toString (
        lib.filter (
          p:
          !(builtins.elem (lib.getName p) [
            "home-manager"
            "hm-session-vars.sh"
            "dummy-fc-dir1"
            "dummy-fc-dir2"
          ])
        ) packages
      )
    );
  hostChecks =
    name: configuration:
    let
      c = configuration.config;
      username = hosts.${name}.user;
      h = c.home-manager.users.${username};
    in
    {
      "${name}/identity" =
        c.dotfiles.primaryUser == username
        && c.networking.hostName == name
        && c.nixpkgs.hostPlatform.system == hosts.${name}.system
        && h.home.username == username
        && h.home.homeDirectory == "${if isDarwin then "/Users" else "/home"}/${username}"
        && h.home.homeDirectory == c.users.users.${username}.home;
      "${name}/embedded-home" =
        c.home-manager.useGlobalPkgs
        && c.home-manager.useUserPackages
        && c.home-manager.backupCommand != null;
      "${name}/nh" =
        h.programs.nh.enable
        && !h.programs.nh.clean.enable
        && h.programs.nh.flake == "${h.xdg.configHome}/dotfiles"
        && h.home.sessionVariables.NH_FLAKE == h.programs.nh.flake;
    }
    // lib.optionalAttrs isDarwin {
      "${name}/nh-hostname" = c.networking.localHostName == name;
      "${name}/key-remapping-migration-order" =
        builtins.elem "writeBoundary" h.home.activation.migrateLegacyKeyRemapping.after
        && builtins.elem "setupLaunchAgents" h.home.activation.migrateLegacyKeyRemapping.before
        &&
          h.home.activation.migrateLegacyKeyRemapping
          == self.homeConfigurations."${username}@${name}".config.home.activation.migrateLegacyKeyRemapping;
      "${name}/user-defaults-ownership" = lib.all (
        user:
        ownsNoPreferences c.home-manager.users.${user}
        && ownsNoPreferences self.homeConfigurations."${user}@${name}".config
      ) (builtins.attrNames c.home-manager.users);
      "${name}/key-remapping-ownership" =
        !(c.launchd.agents ? key-remapping)
        && h.launchd.agents.key-remapping.config.Label == "com.local.KeyRemapping";
      "${name}/gpg-on-demand" = h.services.gpg-agent.enable && !h.launchd.agents.gpg-agent.enable;
      "${name}/boot-safe-launchers" =
        lib.all
          (
            service:
            let
              daemon = c.launchd.daemons.${service};
              args = daemon.serviceConfig.ProgramArguments;
            in
            lib.hasPrefix "/Library/Scripts/nix-darwin/nix-" (builtins.head args)
            && builtins.elemAt args 1 == "-c"
            && builtins.elemAt args 2 == "/bin/wait4path /nix/store && exec ${daemon.command}"
          )
          [
            "activate-system"
            "nix-daemon"
            "nix-gc"
            "nix-optimise"
          ];
      "${name}/nix-store-mount" =
        if name == "juicer" then
          c.launchd.daemons.darwin-store.serviceConfig.ProgramArguments == [
            "/Library/Scripts/nix-darwin/nix-store-mount"
          ]
          && c.launchd.daemons.darwin-store.serviceConfig.RunAtLoad
          && c.launchd.daemons.darwin-store.serviceConfig.KeepAlive.SuccessfulExit == false
        else
          !(c.launchd.daemons ? darwin-store);
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
  darwin-host-set = builtins.attrNames self.darwinConfigurations == hostsOn "-darwin";
  nixos-host-set = builtins.attrNames self.nixosConfigurations == hostsOn "-linux";
  private-modules =
    !(self ? modules)
    && !(self ? homeModules)
    && !(self ? darwinModules)
    && (self.nixosModules or { }) == { };
  canonical-home-outputs =
    builtins.attrNames self.homeConfigurations
    == lib.sort builtins.lessThan (lib.mapAttrsToList (name: h: "${h.user}@${name}") hosts);
  standalone-home-parity = lib.all (
    name:
    let
      c = configurations.${name}.config;
      user = c.dotfiles.primaryUser;
      integrated = c.home-manager.users.${user};
      standalone = self.homeConfigurations."${user}@${name}".config;
    in
    integrated.home.username == standalone.home.username
    && integrated.home.homeDirectory == standalone.home.homeDirectory
    && integrated.home.stateVersion == standalone.home.stateVersion
    && integrated.programs.git.settings.user == standalone.programs.git.settings.user
    && applicationPackages integrated.home.packages == applicationPackages standalone.home.packages
    && builtins.head integrated.home.sessionPath == "${integrated.home.profileDirectory}/bin"
    && builtins.head standalone.home.sessionPath == "${standalone.home.profileDirectory}/bin"
    && builtins.tail integrated.home.sessionPath == builtins.tail standalone.home.sessionPath
    && standalone.home.sessionVariables.NH_FLAKE == "${standalone.xdg.configHome}/dotfiles"
    && integrated.home.activation.configureBackup == standalone.home.activation.configureBackup
    && lib.hasInfix (builtins.unsafeDiscardStringContext c.home-manager.backupCommand) standalone.home.activation.configureBackup.data
  ) (builtins.attrNames configurations);
  no-activation-wrappers =
    lib.all
      (
        name:
        !(builtins.hasAttr name self.packages.${system})
        && !(builtins.hasAttr name (self.apps.${system} or { }))
      )
      [
        "activate"
        "update"
        "default"
      ];
  pinned-nh = self.packages.${system} ? nh;
  no-local-container-pin = !((self.legacyPackages.${system} or { }) ? apple-container);
  no-local-updater = !((self.apps.${system} or { }) ? update-pinned-packages);
} (builtins.attrNames configurations)
