{
  config,
  pkgs,
  isWorkDevice,
  ...
}:
let
  workCasks =
    if isWorkDevice then
      [
        "android-studio"
        "gather"
        "linear-linear"
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
        # TODO: Add more work-specific brews here
      ]
    else
      [ ];
  allBrews = [
    kubectl
  ]
  ++ workBrews;

in
{
  # System-wide Homebrew configuration for all darwin hosts
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    # CLI tools installed via Homebrew formulas
    brews = allBrews;

    # GUI applications installed via Homebrew casks
    casks = allCasks;
  };
}
