{
  username,
  platform,
  isWorkDevice,
  gitConfig,
}:

{
  config,
  pkgs,
  lib,
  ...
}:

let
  personalConfig =
    if !isWorkDevice then
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
      isWorkDevice
      ;
  };

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
      ({ inherit (developmentConfig) programs; })
      ({ inherit (developmentConfig) services; })
      ({ inherit (personalConfig) programs; })
      ({ inherit (personalConfig) accounts; })
      (lib.mkIf (platform == "nixos" && !isWorkDevice) (
        lib.mkMerge (
          map (p: (import p) { inherit config pkgs lib; }) (import ./integrations/nixos/default.nix)
        )
      ))
      (lib.mkIf (platform == "darwin" && !isWorkDevice) (
        lib.mkMerge (
          map (p: (import p) { inherit config pkgs lib; }) (import ./integrations/darwin/default.nix)
        )
      ))
    ];
}
