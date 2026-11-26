{
  lib,
  ponytail,
  isWorkDevice,
  ...
}:
let
  # Ponytail ships one skill per host-agnostic directory. Cursor and other
  # Agent Skills hosts read ~/.agents/skills directly; Claude Code and OpenCode
  # get their own native plugin wiring below.
  skills = [
    "ponytail"
    "ponytail-audit"
    "ponytail-debt"
    "ponytail-gain"
    "ponytail-help"
    "ponytail-review"
  ];
in
{
  config = lib.mkMerge [
    {
      home.file = lib.listToAttrs (
        map (name: {
          name = ".agents/skills/${name}";
          value.source = "${ponytail}/skills/${name}";
        }) skills
      );
    }
    (lib.mkIf isWorkDevice {
      # Custom plugins: link the whole dir via home.file, not programs.claude-code.plugins.
      # That option symlinks each entry, and Claude Code rejects contained hooks as escaping the plugin dir.
      home.file.".claude/skills/ponytail".source = ponytail;
    })
    (lib.mkIf (!isWorkDevice) {
      programs.opencode.settings.plugins = [ "@dietrichgebert/ponytail" ];
    })
  ];
}
