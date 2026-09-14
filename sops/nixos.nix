{
  config,
  username,
  lib,
  pkgs,
  ...
}:
let
  user = config.users.users.${username};
in
lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
  sops.defaultSopsFile = ./secrets/nixos.yaml;

  sops.secrets.immich-api-key = {
    owner = user.name;
  };
  sops.secrets.immich-server-url = {
    owner = user.name;
  };
}
