{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
{
  config = lib.mkIf isWorkDevice {
    programs.t3code = {
      enable = true;
      package = pkgs.t3code.override {
        enableClaude = true;
        enableCodex = false;
        # Reuse our configured claude-code (plugins, hooks) instead of a second nixpkgs copy.
        claude-code = config.programs.claude-code.finalPackage;
      };
      userSettings = {
        storageCleanup = {
          worktreeOnMerge = true;
          worktreeOnDelete = true;
          worktreeSettledAfterDays = 0;
          worktreeKeepWhen = "tracked-changes";
          browserArtifactsAfterDays = 14;
          logsAfterDays = 14;
        };
        providerInstances.codex = {
          driver = "codex";
          enabled = false;
        };
      };
    };
  };
}
