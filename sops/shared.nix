let
  fromShared = {
    sopsFile = ./secrets/shared.yaml;
  };
in
{
  sops.age.keyFile = "/etc/age/keys.txt";

  sops.secrets.smtp_password = fromShared;
  sops.secrets.smb-credentials = fromShared;
}
