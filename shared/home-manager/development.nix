{ pkgs, platform, ... }:

let
  inherit (pkgs) lib;
  
  # Software-engineering-related packages available on both platforms
  commonSoftwareEngineering = with pkgs; [
    vscode
    git
    nodejs_24
    nodePackages.pnpm
  ];
  
  # Software-engineering packages specific to NixOS/Linux
  nixosSoftwareEngineering = with pkgs; lib.optionals (platform == "nixos") [
    github-desktop
  ];
  
  # Software-engineering packages specific to macOS/Darwin
  darwinSoftwareEngineering = with pkgs; lib.optionals (platform == "darwin") [
    # Add darwin-specific software-engineering apps here
  ];
  
in
  commonSoftwareEngineering ++ nixosSoftwareEngineering ++ darwinSoftwareEngineering

