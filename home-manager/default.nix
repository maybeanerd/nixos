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
  core = { ... }: {
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
    inherit username platform isWorkDevice gitConfig;
  };

  home-manager.users.${username} = {
    imports =
      [
        core
        ./personal
        ./development
      ]
      ++ lib.optionals (platform == "nixos" && !isWorkDevice) (import ./integrations/nixos/default.nix)
      ++ lib.optionals (platform == "darwin" && !isWorkDevice) (import ./integrations/darwin/default.nix);
  };
}
