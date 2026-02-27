{ ... }:
{
  imports = [ ./shared.nix ];
  sops.defaultSopsFile = ./secrets/darwin.yaml;

}
