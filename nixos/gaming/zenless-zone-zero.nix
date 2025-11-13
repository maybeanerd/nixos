{
  config,
  pkgs,
  lib,
  aagl-gtk-on-nix,
  ...
}:

{
  imports = [ aagl-gtk-on-nix.nixosModules.default ];

  # Caching for Zenless Zone Zero sleepy launcher
  # https://github.com/an-anime-team/sleepy-launcher/wiki/Installation#-nixos-nixpkg
  nix.settings = lib.mkMerge [
    {
      substituters = [ "https://ezkea.cachix.org" ];
      trusted-public-keys = [ "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=" ];
    }
  ];

  # Game launcher for Zenless Zone Zero
  # https://github.com/an-anime-team/sleepy-launcher/wiki/Installation#-nixos-nixpkg
  programs.sleepy-launcher.enable = true;
}
