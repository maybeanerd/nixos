{
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
lib.mkIf isWorkDevice {
  home.packages = with pkgs; [
    _1password-cli
    bruno
    cocoapods
    cyberduck
    google-cloud-sdk
    google-cloud-sql-proxy
    maestro
    tableplus
    terraform
    watchman
  ];

  programs = {
    claude-code = {
      enable = true;
    };

    zsh = {
      shellAliases = {

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
