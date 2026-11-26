{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
let
  pipelockConfigFile = "${config.home.homeDirectory}/.config/pipelock/pipelock.yaml";
in
{
  config = lib.mkIf isWorkDevice {
    home.file.".claude/CLAUDE.md".text = lib.readFile ../agent.md;

    home.file.".claude/output-styles/ranni.md".text = lib.readFile ../personality.md;

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
