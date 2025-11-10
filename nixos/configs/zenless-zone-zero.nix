{ config, pkgs, lib, ... }:


let
  aagl-gtk-on-nix = import (builtins.fetchTarball "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz");
in
{
  imports = [ aagl-gtk-on-nix.module ];

  # caching for Zenless Zone Zero sleepy launcher https://github.com/an-anime-team/sleepy-launcher/wiki/Installation#-nixos-nixpkg
  nix.settings = {
    substituters = [ "https://ezkea.cachix.org" ];
    trusted-public-keys = [ "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=" ];
  };
  # Game launcher for Zenless Zone Zero https://github.com/an-anime-team/sleepy-launcher/wiki/Installation#-nixos-nixpkg
  programs.sleepy-launcher.enable = true;
}