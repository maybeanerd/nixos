{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ponytail,
  ...
}:
{
  imports = [
    ../agents/claude.nix
    ../agents/zed.nix
  ];

  config = lib.mkIf isWorkDevice {
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

    # GUI apps (GitHub Desktop, Zed, etc.) launch git without devenv/mise on
    # PATH, so lefthook's `assert_lefthook_installed` aborts their hook runs.
    # Skip lefthook session-wide for anything launched outside a shell.
    launchd.agents.lefthook-env = {
      enable = true;
      config = {
        Label = "io.nix.lefthook-env";
        ProgramArguments = [
          "/bin/launchctl"
          "setenv"
          "LEFTHOOK"
          "0"
        ];
        RunAtLoad = true;
      };
    };
  };
}
