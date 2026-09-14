# Logs the (root) nix-daemon into attic once at boot, so the post-build-hook in
# ./default.nix can push without re-authenticating on every build. Personal
# machines only (see ./default.nix); imported only for nixosConfigurations.
{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
lib.mkIf (!isWorkDevice) {
  systemd.services.attic-login = {
    description = "Log the nix-daemon in to the attic cache";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "attic-login" ''
        ${pkgs.attic-client}/bin/attic login nix https://attic.cluster.diluz.io "$(cat ${config.sops.secrets.attic-token.path})"
      '';
    };
  };
}
