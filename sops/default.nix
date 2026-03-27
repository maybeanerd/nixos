# Sops secrets for personal machines only; work devices skip this tree.
{ lib, isWorkDevice, ... }:
{
  imports = lib.optionals (!isWorkDevice) [
    ./shared.nix
    ./darwin.nix
    ./nixos.nix
  ];
}
