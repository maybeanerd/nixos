# Darwin-only Home Manager integrations.
{ lib, pkgs, ... }:
{
  imports = lib.optionals (pkgs.stdenv.isDarwin) [
    ./nas-mount.nix
  ];
}
