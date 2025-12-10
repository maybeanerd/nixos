{
  config,
  pkgs,
  includeWork,
  ...
}:
let
  workCasks =
    if includeWork then
      [
        "cursor"
        "android-studio"
        "gather"
        "linear-linear"
        "figma"
      ]
    else
      [ ];
  allCasks = [
    "github" # GitHub Desktop
    "tidal"
  ]
  ++ workCasks;

  workBrews =
    if includeWork then
      [
        # TODO: Add more work-specific brews here
      ]
    else
      [ ];
  allBrews = [
    # TODO: Add more shared brews here
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
