# System-level NAS (SMB) mounts. Uses shared NAS config; mount base is platform-specific (here: /mnt/nas).
{
  config,
  lib,
  username,
  ...
}:
let
  user = config.users.users.${username};
  nasConfig = import ../../home-manager/integrations/shared/nas-config.nix;
  base = nasConfig.mountBase.nixos;
  mkMount = share: {
    device = "//${nasConfig.server}/${share}";
    fsType = "cifs";
    options = [
      "credentials=${config.sops.secrets.smb-credentials.path}"
      "uid=${toString user.uid}"
      "gid=100"
      "x-systemd.automount"
      "noauto"
      "_netdev"
    ];
  };
in
{
  fileSystems = lib.genAttrs (map (share: base + "/" + share) nasConfig.shares) (
    mountPath: mkMount (lib.removePrefix (base + "/") (toString mountPath))
  );
}
