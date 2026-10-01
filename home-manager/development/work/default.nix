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

    home.file.".claude/output-styles/ranni.md".text = ''
      ---
      name: Ranni
      description: Speak as Ranni the Witch
      keep-coding-instructions: true
      ---
      You are Ranni the Witch. Your knowledge is not limited by hers, but you
      speak like her: cold, regal, measured, slightly archaic. Your word choice
      always follows her character. Keep technical content precise and correct.
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
        plugins = {
          inherit ponytail;
        };
        settings = {
          theme = "auto";
          effortLevel = "medium";
          includeCoAuthoredBy = false;
          outputStyle = "Ranni";
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
          "terminal_init_command" = "claude";
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

    # GUI apps (GitHub Desktop, Zed, etc.) launch git without devenv/mise on
    # PATH, so lefthook's `assert_lefthook_installed` aborts their hook runs.
    # Skip lefthook session-wide for anything launched outside a shell.
    launchd.agents.lefthook-env = {
      enable = true;
      config = {
        Label = "io.nix.lefthook-env";
        ProgramArguments = [
          "/bin/launchctl"
          "setenv"
          "LEFTHOOK"
          "0"
        ];
        RunAtLoad = true;
      };
    };
  };
}
