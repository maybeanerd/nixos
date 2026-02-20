{
  config,
  lib,
  username,
  ...
}:
let
  user = config.users.users.${username};
in
{
  sops.defaultSopsFile = ../secrets/nixos.yaml;

  sops.secrets.smb-credentials = { };

  sops.secrets.immich-api-key = {
    owner = user.name;
    mode = "0400";
  };
  sops.secrets.immich-server-url = {
    owner = user.name;
    mode = "0400";
  };
}
