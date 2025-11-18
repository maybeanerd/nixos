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

  # YubiKey U2F mapping file deployment (pam_u2f)
  # This file contains per-user U2F registrations generated via pamu2fcfg.
  file = {
    ".config/Yubico" = {
      target = ".config/Yubico";
      directory = true;
      mode = "o700";
    };

    ".config/Yubico/u2f_keys" = {
      source = ./u2f_keys;
      mode = "o600";
    };
  };
}
