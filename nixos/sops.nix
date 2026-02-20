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

  # This satisfies the CI assertion for both GPG and Age users.
  # We use a path that 'could' exist, but we don't care if it actually does.
  sops.age.keyFile = lib.mkDefault "/var/lib/sops-nix/key.txt";
}
