{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ponytail,
  ...
}:
let
  pipelockConfigFile = "${config.home.homeDirectory}/.config/pipelock/pipelock.yaml";
in
{
  config = lib.mkIf isWorkDevice {
    home.file.".claude/CLAUDE.md".text = lib.readFile ../agent.md;

    home.file.".claude/output-styles/ranni.md".text = lib.readFile ../personality.md;

    # Custom plugins: link the whole dir via home.file, not programs.claude-code.plugins.
    # That option symlinks each entry, and Claude Code rejects contained hooks as escaping the plugin dir.
    home.file.".claude/skills/ponytail".source = ponytail;

    programs.claude-code = {
      enable = true;
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
                  command = "pipelock claude hook --config ${pipelockConfigFile}";
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
  };
}
