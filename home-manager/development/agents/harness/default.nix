{
  config,
  lib,
  pkgs,
  isWorkDevice,
  osConfig,
  ...
}:
{
  imports = [
    ./opencode.nix
    ./claude.nix
  ];
}
