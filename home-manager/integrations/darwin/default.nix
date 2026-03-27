# Darwin-only Home Manager integrations.
{ lib, platform, ... }:
{
  imports = lib.optionals (platform == "darwin") [
    ./nas-mount.nix
  ];
}
