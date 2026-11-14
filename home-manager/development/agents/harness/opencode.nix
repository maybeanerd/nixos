{
  config,
  lib,
  pkgs,
  isWorkDevice,
  osConfig,
  ...
}:
{
  config = lib.mkIf (!isWorkDevice) {
    home.file.".config/opencode/agent.md".text = lib.readFile ../agent.md;

    programs.opencode = {
      enable = true;
      settings = {
        "$schema" = "https://opencode.ai/config.json";
        provider.google.options.apiKey = "{file:${osConfig.sops.secrets.gemini-api-key.path}}";
      };
    };
  };
}
