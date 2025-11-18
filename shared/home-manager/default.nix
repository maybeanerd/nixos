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
        pkgs = enhancedPkgs;
        inherit platform;
      }
    else
      {
        packages = [ ];
        programs = { };
        file = { };
      };

  developmentConfig =
    if includeDevelopment then
      import ./development.nix {
        pkgs = enhancedPkgs;
        inherit platform shellAliases;
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
        home.file = allFiles;

        home.stateVersion = "25.05";
      }

      # Merge personal program configuration
      ({ inherit (personalConfig) programs; })

      # Merge development program configuration
      ({ inherit (developmentConfig) programs; })
    ];
}
