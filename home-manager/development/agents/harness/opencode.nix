{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
{
  config = lib.mkIf (!isWorkDevice) {
    home.file.".config/opencode/agent.md".text = lib.readFile ../agent.md;

    programs.opencode = {
      enable = true;
      settings = {
        "$schema" = "https://opencode.ai/config.json";
      };
    };
  };
}
