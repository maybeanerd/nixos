# Personal-device integrations only; work machines skip this entire subtree.
{ lib, isWorkDevice, ... }:
{
  imports = lib.optionals (!isWorkDevice) [
    ./nixos
    ./darwin
  ];
}
