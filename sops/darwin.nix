{ ... }:
{
  imports = [ ./shared.nix ];
  sops.defaultSopsFile = ./secrets/darwin.yaml;

  sops.secrets.smb-credentials = { };
}
