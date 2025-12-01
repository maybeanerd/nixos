{
  pkgs,
}:

let
  inherit (pkgs);

  workPackages =
    with pkgs;
     [
      _1password-cli
    ];
in
{
  packages = workPackages;

  # No additional files, services, or programs for now
  file = { };
  services = { };
  programs = { };
}


