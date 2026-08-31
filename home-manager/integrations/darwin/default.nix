# Darwin-only Home Manager integrations.
{ lib, pkgs, ... }:
{
  imports = lib.optionals (pkgs.stdenv.hostPlatform.isDarwin) [
    ./nas-mount.nix
  ];
}
