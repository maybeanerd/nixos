# Logs root into attic once at boot, so the post-build-hook in ./default.nix can
# push without re-authenticating on every build. Personal machines only (see
# ./default.nix); imported only for darwinConfigurations.
{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
lib.mkIf (!isWorkDevice) {
  launchd.daemons.attic-login = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "-c"
        ''${pkgs.attic-client}/bin/attic login nix https://attic.cluster.diluz.io "$(cat ${config.sops.secrets.attic-token.path})"''
      ];
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/var/log/attic-login.log";
      StandardErrorPath = "/var/log/attic-login.log";
    };
  };
}
