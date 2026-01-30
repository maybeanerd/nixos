{
  pkgs,
}:

let
  workPackages = with pkgs; [
    # General dev tooling
    _1password-cli
    tableplus # database GUI
    bruno # API spec GUI
    google-cloud-sql-proxy
    google-cloud-sdk

    # React native tooling
    watchman
    cocoapods
    maestro
  ];
in
{
  packages = workPackages;

  # No additional files, services, or programs for now
  file = { };
  services = { };
  programs = { };
}
