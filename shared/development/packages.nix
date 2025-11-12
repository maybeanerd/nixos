{ pkgs, platform, ... }:

let
  inherit (pkgs) lib;
  
  # Work-related packages available on both platforms
  commonWork = with pkgs; [
    vscode
    git
    nodejs_24
    nodePackages.pnpm
  ];
  
  # Work packages specific to NixOS/Linux
  nixosWork = with pkgs; lib.optionals (platform == "nixos") [
    github-desktop
  ];
  
  # Work packages specific to macOS/Darwin
  darwinWork = with pkgs; lib.optionals (platform == "darwin") [
    # Add darwin-specific work apps here
  ];
  
in
  commonWork ++ nixosWork ++ darwinWork

