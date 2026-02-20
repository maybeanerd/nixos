# Upload screenshots to Immich using the official Node CLI, then delete local copies.
{
  config,
  pkgs,
  username,
  ...
}:
let
  user = config.users.users.${username};
  screenshotsDir = "${user.home}/Pictures/Screenshots";
  uploadScript = pkgs.writeShellScript "immich-screenshot-upload" ''
    set -e
    URL=$(cat ${config.sops.secrets.immich-server-url.path})
    KEY=$(cat ${config.sops.secrets.immich-api-key.path})
    ${pkgs.immich-cli}/bin/immich login-key "$URL" "$KEY"
    ${pkgs.immich-cli}/bin/immich upload --recursive --delete "${screenshotsDir}"
  '';
in
{
  systemd.services.immich-screenshot-upload = {
    description = "Upload screenshots to Immich and delete local copies";
    serviceConfig = {
      Type = "oneshot";
      User = user.name;
      Group = user.group;
    };
    path = [ pkgs.immich-cli ];
    script = "${uploadScript}";
  };

  systemd.timers.immich-screenshot-upload = {
    description = "Run Immich screenshot upload periodically";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
