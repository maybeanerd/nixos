{
  config,
  username,
  ...
}:
let
  fromShared = {
    sopsFile = ./secrets/shared.yaml;
  };
  ownedByUser = {
    owner = config.users.users.${username}.name;
  };
in
{
  sops.age.keyFile = "/etc/age/keys.txt";

  sops.secrets.smtp_password = fromShared;
  sops.secrets.smb-credentials = fromShared;
  sops.secrets.attic-token = fromShared;
  sops.secrets.gemini-api-key = fromShared // ownedByUser;
}
