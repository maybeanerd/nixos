{
  config,
  lib,
  pkgs,
  isWorkDevice,
  username,
  ...
}:
let
  personalSettings = {
    "agent" = {
      "terminal_init_command" = "opencode";
    };
    "language_models" = {
      "openai_compatible" = { };
    };
  };

  workSettings = {
    "agent" = {
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

  agentSettings = if isWorkDevice then workSettings else personalSettings;
in
{
  programs.zed-editor.userSettings = agentSettings;
}
