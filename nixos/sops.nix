{
  config,
  username,
  ...
}:
let
  user = config.users.users.${username};
in
{
  systemd.tmpfiles.rules = [
    "f /var/lib/sops-nix/yubikey-identities.txt 0640 root users -"
  ];
  sops.age.keyFile = "/var/lib/sops-nix/yubikey-identities.txt";

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
