{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
  # Use nixpkgs-unstable for latest packages
  unstablePkgs = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz) {};
in
{
  imports =
    [
      (import "${home-manager}/nixos")
    ];

  # Make Home Manager use the system nixpkgs configuration so it respects
  # the `nixpkgs.config` settings (e.g. allowUnfree).
  home-manager.useGlobalPkgs = true;

  home-manager.users.basti = { pkgs, ... }: {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "git-auto-fetch"
        ];
        theme = "jonathan";
      };
      shellAliases = {
        ll = "ls -la";
        rb = "sudo nixos-rebuild switch";
        # steamscope = "gamescope -w 3440 -h 1440 -f -r 175 --adaptive-sync --rt --steam --expose-wayland -- steam";
        # In steam, use the launch option:
        # gamescope -w 3440 -h 1440 -f -r 175 --adaptive-sync --rt --expose-wayland -- %command% -nolauncher
      };
    };

    home.packages = with pkgs; [
      # general apps
      bitwarden-desktop

      # communication
      thunderbird
      discord
      signal-desktop
      element-desktop

      # media
      tidal-hifi
      vlc

      # gaming
      gamemode
      gamescope
      vulkan-tools
      unstablePkgs.satisfactorymodmanager

      # software development
      vscode
      git
      github-desktop
      nodejs_24
    ];

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.05";
  };
}