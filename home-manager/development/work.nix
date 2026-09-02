{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ponytail,
  username,
  ...
}:
lib.mkIf isWorkDevice {
  home.file.".claude/CLAUDE.md".text = ''
    Always apply ponytail principles by default for all coding tasks. Invoke the ponytail skill automatically on any coding request.
  '';

  home.file.".config/pipelock/pipelock.yaml".text = lib.replaceStrings [ "@PIPELOCK_HOME@" ] [
    "${config.home.homeDirectory}/.pipelock"
  ] (builtins.readFile ./configs/pipelock.yaml);

  # Routes agent traffic through the pipelock proxy started below, so DLP/SSRF/
  # prompt-injection scanning in pipelock.yaml actually sees outbound requests.
  home.sessionVariables = {
    HTTPS_PROXY = "http://127.0.0.1:8888";
    HTTP_PROXY = "http://127.0.0.1:8888";
  };

  # Idempotent: generates the flight-recorder receipt-signing key on first
  # activation only, so pipelock.yaml's signing_key_path is always satisfied
  # before the launchd daemon below tries to start. Never regenerates an
  # existing key — rotating it would break verification of past receipts.
  home.activation.pipelockReceiptKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PIPELOCK_KEY="${config.home.homeDirectory}/.pipelock/keys/flight-recorder-signing.key.json"
    if [ ! -f "$PIPELOCK_KEY" ] && [ -x /opt/homebrew/bin/pipelock ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$PIPELOCK_KEY")"
      $DRY_RUN_CMD /opt/homebrew/bin/pipelock signing key generate \
        --purpose receipt-signing --out "$PIPELOCK_KEY"
    fi
  '';

  launchd.agents.pipelock = {
    enable = true;
    config = {
      Label = "io.nix.pipelock";
      ProgramArguments = [
        "/opt/homebrew/bin/pipelock"
        "run"
        "--config"
        "${config.home.homeDirectory}/.config/pipelock/pipelock.yaml"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/pipelock.err";
      StandardOutPath = "/tmp/pipelock.out";
    };
  };

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
                  command = "pipelock claude hook";
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
}
