# SMB NAS mount at login. Mount base from nas-config (default ~/mnt/nas).
{
  config,
  osConfig,
  pkgs,
  ...
}:
let
  nasConfig = import ../shared/nas-config.nix;
  credentialsPath = "${osConfig.sops.secrets.smb-credentials.path}";
  mountBase = "${config.home.homeDirectory}/${nasConfig.mountBase.darwin}";
  mountScript = pkgs.writeShellScript "nas-mount-all" ''
    set -e
    CREDS="''${1:-${credentialsPath}}"
    if [ ! -r "$CREDS" ]; then
      echo "Credentials not found at $CREDS, skipping NAS mount." >&2
      exit 0
    fi
    USER=$(grep '^username=' "$CREDS" | cut -d= -f2-)
    PASS=$(grep '^password=' "$CREDS" | cut -d= -f2-)
    [ -z "$USER" ] || [ -z "$PASS" ] && { echo "Could not parse credentials." >&2; exit 1; }
    SERVER="${nasConfig.server}"
    BASE="${mountBase}"
    mkdir -p "$BASE"
    for share in ${pkgs.lib.concatStringsSep " " nasConfig.shares}; do
      MP="$BASE/$share"
      mkdir -p "$MP"
      if ! mount | grep -q " on $MP "; then
        mount_smbfs -u "$USER" -P "$PASS" "//$SERVER/$share" "$MP" || true
      fi
    done
  '';
in
{
  launchd.agents.nas-mount = {
    enable = true;
    config = {
      Label = "io.nix.nas-mount";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "${mountScript}"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/tmp/nas-mount.err";
      StandardOutPath = "/tmp/nas-mount.out";
    };
  };
}
