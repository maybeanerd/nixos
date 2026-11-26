{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
let
  # Drop the Claude output-style frontmatter; OpenCode does not parse it.
  personalityBody = lib.last (lib.splitString "---\n" (lib.readFile ../personality.md));
in
{
  config = lib.mkIf (!isWorkDevice) {
    # OpenCode reads AGENTS.md, not agent.md. Inline the personality so the
    # relative "see personality.md" reference also works outside Claude Code.
    home.file.".config/opencode/personality.md".text = lib.readFile ../personality.md;

    programs.opencode = {
      enable = true;
      context = ''
        ${lib.readFile ../agent.md}

        ${personalityBody}
      '';
      settings = {
        "$schema" = "https://opencode.ai/config.json";
        # Skill modules (skills/*.nix) contribute their own plugin entries;
        # Home Manager merges those lists into this settings object.
      };
    };
  };
}
