let
  # Shared personal data. User IDs remain actual login names.
  identity = {
    name = "Jiho Song";
    email = "me@citrus.name";
    signingKey = "C357DE5B22337AA187AF70B40DFA01A9CCF622D0!";
  };
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
