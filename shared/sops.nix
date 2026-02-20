let
  fromShared = {
    sopsFile = ../secrets/shared.yaml;
  };
in
{
  sops.secrets.gmail_password = fromShared;
  sops.secrets.smtp_password = fromShared;
}
