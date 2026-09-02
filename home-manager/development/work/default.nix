{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ponytail,
  username,
  ...
}:
{
  imports = lib.optionals isWorkDevice [ ./pipelock/pipelock.nix ];

  config = lib.mkIf isWorkDevice {
    home.file.".claude/CLAUDE.md".text = ''
      Always apply ponytail principles by default for all coding tasks. Invoke the ponytail skill automatically on any coding request.
    '';

    home.packages = with pkgs; [
      _1password-cli
      bruno
      claude-agent-acp
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
          hooks = {
            PreToolUse = [
              {
                matcher = ".*";
                hooks = [
                  {
                    type = "command";
                    command = "pipelock claude hook --config ${config.home.homeDirectory}/.config/pipelock/pipelock.yaml";
                    timeout = 10;
                  }
                ];
              }
            ];
          };
          permissions = {
            defaultMode = "acceptEdits";
            deny = [
              "Read(*.env)"
              "Read(*.env.*)"
            ];
          };
        };
      };

      zed-editor.userSettings = {
        "disable_ai" = false;
        "edit_predictions" = {
          "provider" = "none";
        };
        "agent" = {
          "dock" = "right";
          "sidebar_side" = "right";
          "show_turn_stats" = true;
          "expand_terminal_card" = false;
          "notify_when_agent_waiting" = "never";
        };
        "agent_servers" = {
          "claude" = {
            "type" = "custom";
            "command" = "${pkgs.claude-agent-acp}/bin/claude-agent-acp";
            "args" = [ "--acp" ];
            "env" = {
              "CLAUDE_CODE_EXECUTABLE" = "/etc/profiles/per-user/${username}/bin/claude";
            };
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
  };
}
