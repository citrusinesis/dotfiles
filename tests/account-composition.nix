{
  inputs,
  lib,
  system,
  features,
}:
let
  isDarwin = lib.hasSuffix "-darwin" system;
  backend = if isDarwin then "darwin" else "nixos";
  typed =
    records:
    (lib.evalModules {
      modules = [
        ../modules/inventory.nix
        { dotfiles.inventory = records; }
      ];
    }).config.dotfiles.inventory;
  build = records: import ../lib/mk-configurations.nix { inherit inputs lib; } (typed records);
  shared = {
    homeManager = ./fixtures/account-shared-home.nix;
    ${backend} = ./fixtures/account-shared-system.nix;
  };
  names = [
    "alice"
    "bob"
  ];
  records = {
    users = lib.genAttrs names (name: {
      aspect = {
        includes = [ shared ];
        homeManager.home.sessionVariables.TEST_USER = name;
      };
    });
    hosts.fixture = {
      inherit system backend;
      primaryAccount = "alice@fixture";
      aspect = {
        includes = [ shared ];
        homeManager = { pkgs, ... }: {
          home.sessionVariables.TEST_HOST = "fixture";
          home.sessionVariables.TEST_PACKAGE = toString pkgs.hello;
        };
        ${backend}.system.stateVersion = if isDarwin then 5 else "25.11";
      };
    };
    accounts = lib.genAttrs (map (name: "${name}@fixture") names) (id: {
      home.stateVersion = "25.11";
      aspect = {
        includes = [ shared ];
        homeManager.home.sessionVariables.TEST_ACCOUNT = id;
        ${backend}.users.users.${lib.removeSuffix "@fixture" id} = {
          description = id;
        }
        // lib.optionalAttrs (!isDarwin) { isNormalUser = true; };
      };
    });
  };
  outputs = build records;
  c = outputs.${if isDarwin then "darwinConfigurations" else "nixosConfigurations"}.fixture.config;
  unmanagedRecords = {
    users = { inherit (records.users) alice; };
    hosts.laptop = {
      inherit system;
      backend = "unmanaged";
      aspect.includes = [
        features.core
        features.fonts
      ]
      ++ lib.optionals isDarwin [
        features.darwin
        features.ghostty
      ];
    };
    accounts."alice@laptop".home = {
      directory = "/srv/home/alice";
      stateVersion = "25.11";
    };
  };
  unmanaged = build unmanagedRecords;
  uh = unmanaged.homeConfigurations."alice@laptop".config;
  valid =
    records:
    (builtins.tryEval (
      builtins.deepSeq (import ../lib/resolve-inventory.nix { inherit lib; } (typed records)) true
    )).success;
  count = value: values: builtins.length (lib.filter (x: x == value) values);
in
{
  checks = {
    all-accounts-have-both-homes =
      builtins.attrNames c.home-manager.users == names
      && builtins.attrNames outputs.homeConfigurations == map (n: "${n}@fixture") names;
    account-isolation-and-parity = lib.all (
      name:
      let
        h = c.home-manager.users.${name};
        standalone = outputs.homeConfigurations."${name}@fixture".config;
        vars = home: lib.filterAttrs (n: _: lib.hasPrefix "TEST_" n) home.home.sessionVariables;
      in
      c.users.users.${name}.description == "${name}@fixture"
      && h.home.username == name
      && h.home.sessionVariables.TEST_HOST == "fixture"
      && h.home.sessionVariables.TEST_USER == name
      && h.home.sessionVariables.TEST_ACCOUNT == "${name}@fixture"
      && h.home.sessionVariables.TEST_PACKAGE == toString c.nixpkgs.pkgs.hello
      && vars h == vars standalone
      && count "/shared-feature" h.home.sessionPath == 1
    ) names;
    shared-native-module-deduplication =
      count "hello" (map lib.getName c.environment.systemPackages) == 1;
    primary-user = c.dotfiles.primaryUser == "alice";
    unmanaged-only-home = unmanaged.darwinConfigurations == { } && unmanaged.nixosConfigurations == { };
    unmanaged-identity = uh.home.username == "alice" && uh.home.homeDirectory == "/srv/home/alice";
    unmanaged-fonts = builtins.elem "nerd-fonts-hack" (map lib.getName uh.home.packages);
    unmanaged-platform =
      if isDarwin then
        !uh.targets.darwin.linkApps.enable
        && !uh.targets.darwin.copyApps.enable
        && builtins.elem "/Applications/Ghostty.app/Contents/MacOS" uh.home.sessionPath
        && builtins.elem "/opt/homebrew/bin" uh.home.sessionPath
      else
        uh.targets.genericLinux.enable && uh.fonts.fontconfig.enable;
    reject-invalid-account = !valid (records // { accounts.alice.home.stateVersion = "25.11"; });
    reject-missing-user =
      !valid (records // { accounts."missing@fixture".home.stateVersion = "25.11"; });
    reject-missing-host = !valid (records // { accounts."alice@missing".home.stateVersion = "25.11"; });
    reject-wrong-primary =
      !valid (
        records
        // {
          hosts.fixture = records.hosts.fixture // {
            primaryAccount = "alice@elsewhere";
          };
        }
      );
    reject-backend-mismatch =
      !valid (
        records
        // {
          hosts.fixture = records.hosts.fixture // {
            backend = if isDarwin then "nixos" else "darwin";
          };
        }
      );
  };
  evaluations = {
    unmanaged-home = uh.home.activationPackage.drvPath;
    second-integrated-home = c.home-manager.users.bob.home.activationPackage.drvPath;
    second-standalone-home = outputs.homeConfigurations."bob@fixture".activationPackage.drvPath;
  };
}
