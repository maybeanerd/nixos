{ lib, includePersonal, ... }:

{
  imports = [
    ./homebrew
  ]
  ++ lib.optionals includePersonal [
    ./sops.nix
    ../shared/sops.nix
  ];
}
