{
  pkgs,
  username,
  ...
}:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = true;
  };

  users.users.${username}.packages = with pkgs; [
    gamemode
    gamescope
    vulkan-tools
    satisfactorymodmanager
    heroic # Game launcher for Epic Games
  ];
}
