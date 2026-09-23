{
  config,
  pkgs,
  isWorkDevice,
  username,
  homebrew-core,
  homebrew-cask,
  homebrew-luckypipewrench-tap,
  homebrew-skyhookio-tap,
  ...
}:
let
  workCasks =
    if isWorkDevice then
      [
        "linear"
        "figma"
        "redis-insight"
      ]
    else
      [ ];

  personalCasks =
    if !isWorkDevice then
      [
        "private-internet-access"
        "calibre"
        "nextcloud"
        "libreoffice"
      ]
    else
      [ ];

  allCasks = [
    "github" # GitHub Desktop
    "tidal"
  ]
  ++ workCasks
  ++ personalCasks;

  workBrews =
    if isWorkDevice then
      [
        "luckypipewrench/tap/pipelock"
      ]
    else
      [ ];
  allBrews = [
    "kubectl"
    "skyhook-io/tap/radar"
  ]
  ++ workBrews;

in
{
  # Declaratively install/manage the Homebrew bin itself
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
    autoMigrate = true; # move existing homebrew installs
    mutableTaps = false;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "luckypipewrench/homebrew-tap" = homebrew-luckypipewrench-tap;
      "skyhook-io/homebrew-tap" = homebrew-skyhookio-tap;
    };
  };

  # System-wide Homebrew configuration for all darwin hosts
  homebrew = {
    enable = true;

    onActivation = {
      # autoUpdate omitted: nix-homebrew forces HOMEBREW_NO_AUTO_UPDATE=1 with mutableTaps = false
      upgrade = true;
      cleanup = "uninstall";
    };

    # Declare the same taps as `nix-homebrew.taps` so `onActivation.cleanup = "uninstall"`
    # doesn't try to `brew untap` an immutable, nix-managed tap (homebrew/core is always
    # exempt from cleanup).
    taps = [
      "homebrew/cask"
      "luckypipewrench/tap"
      "skyhook-io/tap"
    ];

    # CLI tools installed via Homebrew formulas
    brews = allBrews;

    # GUI applications installed via Homebrew casks
    casks = allCasks;
  };
}
