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
      "openai_compatible" = {
        "Hetzner" = {
          "api_url" = "https://inference.hetzner.com/api/v1";
          "available_models" = [
            {
              "name" = "Qwen/Qwen3.6-35B-A3B-FP8";
              "display_name" = "Qwen3.6 35B (Hetzner)";
              "max_tokens" = 262144;
              "max_output_tokens" = 32768;
              "capabilities" = {
                "tools" = true;
                "images" = true;
                "parallel_tool_calls" = false;
                "prompt_cache_key" = false;
              };
            }
          ];
        };
      };
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
