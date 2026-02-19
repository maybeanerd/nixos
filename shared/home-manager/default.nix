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
        inherit platform pkgs;
      }
    else
      {
        packages = [ ];
        programs = { };
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

      # Darwin-only: app targets and optionally alias-based setup for managed (work) devices.
      (
        {
          config,
          pkgs,
          lib,
          ...
        }:
        lib.mkIf (platform == "darwin") (
          let
            copyApps = {
              # On personal: copyApps so Spotlight can find the apps.
              targets.darwin.copyApps.enable = !includeWork;
            };
            # On managed (work): create macOS aliases so launchers find apps without App Management permissions
            # which are required by copyApps (blocked by MDM).
            aliasApps =
              if includeWork then
                let
                  hmAppsEnv = pkgs.buildEnv {
                    name = "hm-applications";
                    paths = allPackages;
                    pathsToLink = [ "/Applications" ];
                  };
                in
                {
                  home.activationScripts.appAliases = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                    echo "setting up ~/Applications/Home Manager Apps (aliases)..." >&2
                    rm -rf "$HOME/Applications/Home Manager Apps"
                    mkdir -p "$HOME/Applications/Home Manager Apps"
                    for app in "${hmAppsEnv}/Applications"/*; do
                      [ -e "$app" ] || continue
                      name=$(basename "$app")
                      target=$(readlink "$app" || echo "$app")
                      ${pkgs.mkalias}/bin/mkalias "$target" "$HOME/Applications/Home Manager Apps/$name"
                    done
                  '';
                }
              else
                { };
          in
          copyApps // aliasApps
        )
      )

      # Merge development programs
      ({ inherit (developmentConfig) programs; })
      # Merge development services
      ({ inherit (developmentConfig) services; })

      # Merge personal programs
      ({ inherit (personalConfig) programs; })

    ];
}
