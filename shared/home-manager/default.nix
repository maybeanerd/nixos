{
  username,
  platform,
  includePersonal,
  includeWork,
  gitConfig,
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
        inherit platform pkgs config;
      }
    else
      {
        packages = [ ];
        programs = { };
        accounts = { };
        file = { };
      };

  developmentConfig = import ./development {
    inherit
      platform
      pkgs
      username
      gitConfig
      includeWork
      ;
  };

  # Combine configs
  allPackages = personalConfig.packages ++ developmentConfig.packages;
  allFiles = lib.mkMerge [
    personalConfig.file
    developmentConfig.file
  ];

in
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Keep textual backups of files managed by home-manager with .backup extension
  home-manager.backupFileExtension = "backup";

  home-manager.users.${username} =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    lib.mkMerge [
      # Base configuration
      {
        programs.firefox = {
          enable = true;
          # profiles = { ... };
        };

        home.packages = allPackages;
        home.file = allFiles;

        home.stateVersion = "25.11";
      }

      # Merge development config
      ({ inherit (developmentConfig) programs; })
      ({ inherit (developmentConfig) services; })

      # Merge personal config
      ({ inherit (personalConfig) programs; })
      ({ inherit (personalConfig) accounts; })

    ];
}
