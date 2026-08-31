# NixOS-only Home Manager integrations (user-level, after login).
{ lib, pkgs, ... }:
{
  imports = lib.optionals (pkgs.stdenv.hostPlatform.isLinux) [
    ./immich-screenshot-upload.nix
  ];
}
