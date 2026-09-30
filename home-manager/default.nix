{
  username,
  isWorkDevice,
  gitConfig,
  ponytail,
  pkgs,
  ...
}:

let
  core =
    { ... }:
    {
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
      pkgs
      gitConfig
      ponytail
      ;
  };

  home-manager.users.${username} = {
    imports = [
      core
      ./firefox
      ./personal
      ./development
      ./integrations
    ];
  };
}
