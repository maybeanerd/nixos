{
  username,
  platform,
  includePersonal ? true,
  includeDevelopment ? true,
}:

{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Import package lists and configs based on what's enabled
  personalConfig =
    if includePersonal then
      import ./personal {
        inherit platform pkgs;
      }
    else
      {
        packages = [ ];
        programs = { };
        file = { };
      };

  developmentConfig =
    if includeDevelopment then
      import ./development {
        inherit platform pkgs shellAliases;
      }
    else
      {
        packages = [ ];
        programs = { };
        file = { };
      };

  # Combine configs
  allPackages = personalConfig.packages ++ developmentConfig.packages;
  allFiles = lib.mkMerge [
    personalConfig.file
    developmentConfig.file
  ];

  # Shell aliases based on platform
  shellAliases = {
    ll = "ls -la";
  }
  // (
    if platform == "darwin" then
      {
        rb = "sudo darwin-rebuild switch";
      }
    else
      {
        rb = "sudo nixos-rebuild switch";
      }
  );

in
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Keep textual backups of files managed by home-manager with .backup extension
  home-manager.backupFileExtension = "backup";

  home-manager.users.${username} =
    { pkgs, ... }:
    lib.mkMerge [
      # Base configuration
      {
        programs.firefox = {
          enable = true;
          # profiles = { ... };
        };

        home.packages = allPackages;
        home.file = lib.mkMerge [
          {
            # YubiKey U2F mapping file deployment (pam_u2f)
            # This file contains per-user U2F registrations generated via pamu2fcfg.
            ".config/Yubico/u2f_keys" = {
              target = ".config/Yubico/u2f_keys";
              text = "${username}:JCA7Tjva+fImbo3LF4F4Jki0Kh12HLq1uTqZ1Qd/8AKDRpN8NvIrAI3jqNDNFpqkaQEjzFTnpx5f2L2Mq6L8bw==,DVL13wkNExtCeNTvtpcbqWH4GGnexDHmKPj6HQHt+uVHeIXg4w2BUB4lrCqHWdKQRJGIZai+TVTOktysxiz1qg==,es256,+presence:V26nRWI7mQpkDaifK6VqzAj4MSzhI2z+rvoeULWQGYYZltWrnn2djgp7Cs3daGm4KpIAFJVaM/SB4WgABzQoYA==,ZpRIVW6cvSuv6Ipj/tkP26Iovym/7Brsil7AFcBFzuPTteD8HYeT/BFQTv34mP05+h3lVOZrIs0AYLVtxJ5qLw==,es256,+presence";
            };
          }
          allFiles
        ];

        home.stateVersion = "25.05";
      }

      # Merge personal program configuration
      ({ inherit (personalConfig) programs; })

      # Merge development program configuration
      ({ inherit (developmentConfig) programs; })
    ];
}
