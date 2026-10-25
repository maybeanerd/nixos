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
        provider.hetzner = {
          npm = "@ai-sdk/openai-compatible";
          name = "Hetzner";
          options = {
            baseURL = "https://inference.hetzner.com/api/v1";
            apiKey = "{file:${osConfig.sops.secrets.hetzner-api-key.path}}";
          };
          models."Qwen/Qwen3.6-35B-A3B-FP8" = {
            name = "Qwen3.6 35B";
            tool_call = true;
            limit = {
              context = 262144;
              output = 32768;
            };
            modalities = {
              input = [
                "text"
                "image"
              ];
              output = [ "text" ];
            };
          };
          models."Qwen3.8-27B" = {
            name = "Qwen3.8 27B";
            tool_call = true;
            limit = {
              context = 262144;
              output = 32768;
            };
            modalities = {
              input = [
                "text"
                "image"
              ];
              output = [ "text" ];
            };
          };
        };
        model = "hetzner/Qwen/Qwen3.6-35B-A3B-FP8";
      };
    };
  };
}
