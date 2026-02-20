{
  config,
  lib,
  username,
  ...
}:
let
  user = config.users.users.${username};
  nasServer = "cube03";
  nasShares = [
    "audiobookshelfAudiobooks"
    "immichExternalLibrary"
    "jellyfinMedia"
    "PiNAS"
  ];
  mkMount = share: {
    device = "//${nasServer}/${share}";
    fsType = "cifs";
    options = [
      "credentials=${config.sops.secrets.smb-credentials.path}"
      "uid=${toString user.uid}"
      "gid=100" # Explicit GID for the 'users' group
      "x-systemd.automount"
      "noauto"
      "_netdev"
    ];
  };
in
{
  fileSystems = lib.genAttrs (map (share: "/mnt/nas/${share}") nasShares) (
    mountPath: mkMount (lib.removePrefix "/mnt/nas/" mountPath)
  );
}
