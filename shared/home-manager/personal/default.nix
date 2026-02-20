{ pkgs, platform, ... }:

let
  inherit (pkgs) lib;

  commonPersonal = with pkgs; [
    immich-go
  ];

  nixosPersonal =
    with pkgs;
    lib.optionals (platform == "nixos") [
      bitwarden-desktop
      discord
      signal-desktop
      element-desktop
      fluffychat
      tidal-hifi
      vlc
      libreoffice-fresh
      pavucontrol # for audio management
      prusa-slicer
      libation
    ];

  darwinPersonal =
    with pkgs;
    lib.optionals (platform == "darwin") [
      # TODO add supported apps here
    ];

in
{
  packages = commonPersonal ++ nixosPersonal ++ darwinPersonal;

  programs = {
    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
  };

  file = {
  };
}
