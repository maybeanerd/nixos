{ lib, platform, ... }:
lib.mkIf (platform == "darwin") {
  sops.defaultSopsFile = ./secrets/darwin.yaml;
}
