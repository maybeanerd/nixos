# Upload screenshots to Immich hourly. User-level so sops secrets are available after login.
{
  config,
  osConfig,
  pkgs,
  ...
}:
let
  screenshotsDir = "${config.home.homeDirectory}/Pictures/Screenshots";
  immichServerUrlPath = "${osConfig.sops.secrets.immich-server-url.path}";
  immichApiKeyPath = "${osConfig.sops.secrets.immich-api-key.path}";
  uploadScript = pkgs.writeShellScript "immich-screenshot-upload" ''
    set -e
    URL=$(cat ${immichServerUrlPath})
    KEY=$(cat ${immichApiKeyPath})
    ${pkgs.immich-cli}/bin/immich login-key "$URL" "$KEY"
    ${pkgs.immich-cli}/bin/immich upload --recursive --album --delete "${screenshotsDir}"
  '';
in
{
  systemd.user.services.immich-screenshot-upload = {
    Unit.Description = "Upload screenshots to Immich and delete local copies";
    Service = {
      Type = "oneshot";
      ExecStart = "${uploadScript}";
      PATH = "${pkgs.lib.makeBinPath [ pkgs.immich-cli ]}";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.timers.immich-screenshot-upload = {
    Unit.Description = "Run Immich screenshot upload hourly";
    Timer.OnCalendar = "hourly";
    Timer.Persistent = true;
    Install.WantedBy = [ "timers.target" ];
  };
}
