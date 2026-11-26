{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ponytail,
  osConfig,
  ...
}:
{
  imports = [
    ./harness
    ./skills
    ./pipelock
    ./zed.nix
  ];
}
