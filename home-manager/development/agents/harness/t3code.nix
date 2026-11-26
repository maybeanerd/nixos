{
  config,
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
{
  config = {
    # No settings key exists for this; the desktop app copies it from the login shell.
    home.sessionVariables.T3CODE_TELEMETRY_ENABLED = "false";

    programs.t3code = {
      enable = true;
      package = pkgs.t3code.override (
        {
          enableCodex = false;
        }
        // lib.optionalAttrs isWorkDevice {
          enableClaude = true;
          # Reuse our configured claude-code (plugins, hooks) instead of a second nixpkgs copy.
          claude-code = config.programs.claude-code.finalPackage;
        }
        // lib.optionalAttrs (!isWorkDevice) {
          enableOpencode = true;
          # Use the same OpenCode build that Home Manager configures.
          opencode = config.programs.opencode.package;
        }
      );
      userSettings = {
        defaultRuntimeMode = "full-access";
        # Providers are pinned by nix; the "update available" notices are noise.
        enableProviderUpdateChecks = false;
        pullRequestMergeMethod = "squash";
        # Also lets the review diff open worktrees there; it only accepts managed worktree folders.
        worktreesDirectory = "~/Documents/git-repos/worktrees";
        storageCleanup = {
          worktreeOnMerge = true;
          worktreeOnDelete = true;
          worktreeSettledAfterDays = 0;
          worktreeKeepWhen = "tracked-changes";
          browserArtifactsAfterDays = 14;
          logsAfterDays = 14;
        };
        providerInstances = {
          codex = {
            driver = "codex";
            enabled = false;
          };
        }
        // lib.optionalAttrs isWorkDevice {
          # OpenCode is only installed and configured on personal devices.
          opencode = {
            driver = "opencode";
            enabled = false;
          };
          claudeAgent = {
            driver = "claudeAgent";
            enabled = true;
          };
        }
        // lib.optionalAttrs (!isWorkDevice) {
          opencode = {
            driver = "opencode";
            enabled = true;
          };
          # Claude Code is only installed and configured on work devices.
          claudeAgent = {
            driver = "claudeAgent";
            enabled = false;
          };
        };
      };
    };
  };
}
