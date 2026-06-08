{
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
lib.mkIf isWorkDevice {
  home.packages = with pkgs; [
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
    cyberduck
  ];

  programs = {
    claude-code = {
      enable = true;
    };

    zsh = {
      shellAliases = {
        ca = "cursor-agent";
      };
      initContent = ''
        # Android SDK configuration
        export ANDROID_HOME=$HOME/Library/Android/sdk
        export PATH=$PATH:$ANDROID_HOME/emulator
        export PATH=$PATH:$ANDROID_HOME/platform-tools
      '';
    };
  };
}
