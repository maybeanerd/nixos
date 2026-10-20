{
  config,
  username,
  lib,
  pkgs,
  ...
}:
let
  ownedByUser = {
    owner = config.users.users.${username}.name;
  };
in
lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
  sops.defaultSopsFile = ./secrets/nixos.yaml;

  sops.secrets.immich-api-key = ownedByUser;
  sops.secrets.immich-server-url = ownedByUser;
}
