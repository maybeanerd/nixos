let
  fromShared = {
    sopsFile = ../secrets/shared.yaml;
  };
in
{
  sops.secrets."empty-value" = fromShared;
}
