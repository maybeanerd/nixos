{ pkgs, platform, ... }:

let
  inherit (pkgs) lib;

  commonPersonal = with pkgs; [
  ];

  nixosPersonal =
    with pkgs;
    lib.optionals (platform == "nixos") [
      bitwarden-desktop
      discord
      signal-desktop
      element-desktop
      tidal-hifi
      vlc
      libreoffice-fresh
      pavucontrol # for audio management
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
