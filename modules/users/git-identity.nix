let
  identity = import ./identity.nix;
in
{
  programs.git = {
    signing = {
      format = "openpgp";
      key = identity.signingKey;
      signByDefault = true;
    };
    settings.user = { inherit (identity) name email; };
  };
}
