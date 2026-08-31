{ lib, pkgs, ... }:
lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
  sops.defaultSopsFile = ./secrets/darwin.yaml;
}
