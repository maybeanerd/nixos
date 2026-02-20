{
  config,
  username,
  ...
}:
let
  user = config.users.users.${username};
in
{
  # Allow the system to use its own SSH key for decryption
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # In theory, allow yubikey support for sops decrypt during build, but it doesn't work
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
