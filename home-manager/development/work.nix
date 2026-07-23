{
  lib,
  pkgs,
  isWorkDevice,
  ponytail,
  ...
}:
lib.mkIf isWorkDevice {
  home.file.".claude/CLAUDE.md".text = ''
    Always apply ponytail principles by default for all coding tasks. Invoke the ponytail skill automatically on any coding request.
  '';

  home.packages = with pkgs; [
    _1password-cli
    bruno
    cyberduck
    google-cloud-sdk
    google-cloud-sql-proxy
    tableplus
    terraform
  ];

  programs = {
    claude-code = {
      enable = true;
      plugins = [ ponytail ];
      settings = {
        theme = "auto";
        effortLevel = "medium";
        includeCoAuthoredBy = false;
        permissions = {
          defaultMode = "acceptEdits";
          deny = [
            "Read(*.env)"
            "Read(*.env.*)"
          ];
        };
      };
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
