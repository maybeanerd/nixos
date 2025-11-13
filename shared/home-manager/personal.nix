{ pkgs, platform, ... }:

let
  inherit (pkgs) lib;

  commonPersonal = with pkgs; [
    vlc
  ];

  nixosPersonal =
    with pkgs;
    lib.optionals (platform == "nixos") [
      bitwarden-desktop
      discord
      signal-desktop
      element-desktop
      tidal-hifi
    ];

  darwinPersonal =
    with pkgs;
    lib.optionals (platform == "darwin") [
    ];

in
{
  packages = commonPersonal ++ nixosPersonal ++ darwinPersonal;

  programs = lib.optionalAttrs (platform == "nixos") {
    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
  };
}
