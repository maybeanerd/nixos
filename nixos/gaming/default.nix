{
  pkgs,
  username,
  xmage,
  system,
  ...
}:

let
  # Create xmage package from flake
  xmagePkg = xmage.packages.${system}.default;
in

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
    xmagePkg
    heroic # Game launcher for Epic Games
  ];
}
