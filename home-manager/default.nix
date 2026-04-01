{
  username,
  isWorkDevice,
  gitConfig,
  ...
}:

let
  core =
    { ... }:
    {
      programs.firefox = {
        enable = true;
        # profiles = { ... };
      };

      home.stateVersion = "25.11";
    };
in
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # Keep textual backups of files managed by home-manager with .backup extension
  home-manager.backupFileExtension = "backup";

  home-manager.extraSpecialArgs = {
    inherit
      username
      isWorkDevice
      gitConfig
      ;
  };

  home-manager.users.${username} = {
    imports = [
      core
      ./personal
      ./development
      ./integrations
    ];
  };
}
