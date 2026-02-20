let
  fromShared = {
    sopsFile = ../secrets/shared.yaml;
  };
in
{
  sops.age.keyFile = "/var/lib/sops-nix/yubikey-identities.txt";

  sops.secrets."empty-value" = fromShared;
}
