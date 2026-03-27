{
  config,
  username,
  lib,
  platform,
  ...
}:
let
  user = config.users.users.${username};
in
lib.mkIf (platform == "nixos") {
  sops.defaultSopsFile = ./secrets/nixos.yaml;

  # In theory, allow yubikey support for sops decrypt during build, but it doesn't work
  sops.age.keyFile = "/var/lib/sops-nix/yubikey-identities.txt";

  sops.secrets.immich-api-key = {
    owner = user.name;
    mode = "0400";
  };
  sops.secrets.immich-server-url = {
    owner = user.name;
    mode = "0400";
  };
}
