{ lib, pkgs, ... }:
lib.mkIf (pkgs.stdenv.isDarwin) {
  sops.defaultSopsFile = ./secrets/darwin.yaml;
}
