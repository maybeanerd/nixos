{ config, pkgs, lib, username, ... }:

{
  # Import game-specific configurations
  imports = [
    ./zenless-zone-zero.nix
  ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Gaming packages for the main user
  users.users.${username}.packages = with pkgs; [
    gamemode
    gamescope
    vulkan-tools
    unstable.satisfactorymodmanager
  ];
}
