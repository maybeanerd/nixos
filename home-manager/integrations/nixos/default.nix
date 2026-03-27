# NixOS-only Home Manager integrations (user-level, after login).
{ lib, platform, ... }:
{
  imports = lib.optionals (platform == "nixos") [
    ./immich-screenshot-upload.nix
  ];
}
