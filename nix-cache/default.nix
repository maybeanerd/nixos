# Declarative config for the public-read "nix" attic cache at attic.cluster.diluz.io.
# Substituter/public-key aren't secret and apply to every machine
# the cache is public-read, so pulling needs no token.
#
# Pushing is still authenticated and personal-machines/cicd-only. It uses Nix's post-build-hook, which
# only fires for paths actually built locally, so we never re-upload packages that
# are already cached upstream. The hook just needs `attic` already logged in; that
# one-time login is done by a platform-specific oneshot service in
# ./linux-push.nix / ./darwin-push.nix.
{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
{
  config = lib.mkMerge [
    {
      nix.settings = {
        substituters = [ "https://attic.cluster.diluz.io/nix" ];
        trusted-public-keys = [ "nix:MFl/jo1emc+Wx7DgeiPo/oc12KPRt5G7M2v7ljqP3OI=" ];
      };
    }
    (lib.mkIf (!isWorkDevice) {
      environment.systemPackages = [ pkgs.attic-client ];

      # Fires only for paths actually built in this run.
      nix.settings.post-build-hook = pkgs.writeShellScript "attic-post-build-hook" ''
        set -eu
        set -f
        export IFS=' '
        exec ${pkgs.attic-client}/bin/attic push nix $OUT_PATHS
      '';
    })
  ];
}
