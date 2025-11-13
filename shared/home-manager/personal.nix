{ pkgs, platform, ... }:

let
  inherit (pkgs) lib;
  
  # Personal apps available on both platforms
  commonPersonal = with pkgs; [
    vlc
  ];
  
  # Personal apps specific to NixOS/Linux
  nixosPersonal = with pkgs; lib.optionals (platform == "nixos") [
    bitwarden-desktop
    thunderbird
    discord
    signal-desktop
    element-desktop
    tidal-hifi
  ];
  
  # Personal apps specific to macOS/Darwin
  darwinPersonal = with pkgs; lib.optionals (platform == "darwin") [
    # Add darwin-specific personal apps here
  ];
  
in
  commonPersonal ++ nixosPersonal ++ darwinPersonal

