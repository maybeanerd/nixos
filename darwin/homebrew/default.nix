{ config, pkgs, ... }:

{
  # System-wide Homebrew configuration for all darwin hosts
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    # GUI applications installed via Homebrew casks
    casks = [
      # GitHub Desktop
      "github"
    ];
  };
}
