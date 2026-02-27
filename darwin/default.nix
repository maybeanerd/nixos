{ lib, isWorkDevice, ... }:

{
  imports = [
    ./homebrew
  ]
  ++ lib.optionals (!isWorkDevice) [
    ../sops/darwin.nix
  ];
}
