{ config, lib, pkgs, isWorkDevice, ponytail, osConfig, ... }:
{
  imports = [
    ./harness
    ./pipelock
    ./zed.nix
  ];
}
