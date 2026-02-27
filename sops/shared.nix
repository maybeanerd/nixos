let
  fromShared = {
    sopsFile = ./secrets/shared.yaml;
  };
in
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.smtp_password = fromShared;
  sops.secrets.smb-credentials = fromShared;
}
