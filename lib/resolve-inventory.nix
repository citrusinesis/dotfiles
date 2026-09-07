{ lib }:
{
  users,
  hosts,
  accounts,
}:
let
  resolvedAccounts = lib.mapAttrs (
    id: account:
    let
      parts = builtins.match "([^@]+)@([^@]+)" id;
      userName = builtins.elemAt parts 0;
      hostName = builtins.elemAt parts 1;
    in
    assert lib.assertMsg (parts != null) "Account ${id}: expected user@host";
    assert lib.assertMsg (
      users ? ${userName} && hosts ? ${hostName}
    ) "Account ${id}: User or Host is not registered";
    account
    // {
      inherit id userName hostName;
      home = account.home // {
        directory =
          if account.home.directory != null then
            account.home.directory
          else
            "${if lib.hasSuffix "-darwin" hosts.${hostName}.system then "/Users" else "/home"}/${userName}";
      };
    }
  ) accounts;
in
{
  inherit users;
  accounts = resolvedAccounts;
  hosts = lib.mapAttrs (
    name: host:
    assert lib.assertMsg (
      host.backend == "unmanaged"
      || lib.hasSuffix (if host.backend == "darwin" then "-darwin" else "-linux") host.system
    ) "Host ${name}: backend does not support ${host.system}";
    assert lib.assertMsg (
      host.backend == "unmanaged"
      || (
        resolvedAccounts ? ${host.primaryAccount}
        && resolvedAccounts.${host.primaryAccount}.hostName == name
      )
    ) "Host ${name}: primaryAccount must reference an Account on this Host";
    host // { inherit name; }
  ) hosts;
}
