{
  pkgs,
}:

let
  workPackages = with pkgs; [
    _1password-cli
    tableplus
    bruno
    google-cloud-sql-proxy
    google-cloud-sdk
    watchman
    cocoapods
    maestro
    cursor-cli
    terraform
  ];
in
{
  packages = workPackages;
  file = { };
  services = { };
  programs = { };
}
