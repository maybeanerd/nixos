{
  config,
  lib,
  pkgs,
  ...
}:
let
  pipelockHome = "${config.home.homeDirectory}/.pipelock";
  pipelockConfigFile = "${config.home.homeDirectory}/.config/pipelock/pipelock.yaml";
  pipelockYaml = builtins.readFile ./pipelock.yaml;
  pipelockConf = lib.replaceStrings [ "@PIPELOCK_HOME@" ] [ "${pipelockHome}" ] pipelockYaml;
in
{
  home.file.".config/pipelock/pipelock.yaml".text = pipelockConf;

  # Proxy env vars set globally; pipelock daemon must be running for them to take effect
  home.sessionVariables = {
    HTTPS_PROXY = "http://127.0.0.1:8888";
    HTTP_PROXY = "http://127.0.0.1:8888";
  };

  # Idempotent: generates the flight-recorder receipt-signing key on first activation only
  home.activation.pipelockReceiptKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PIPELOCK_KEY="${pipelockHome}/keys/flight-recorder-signing.key.json"
    if [ ! -f "$PIPELOCK_KEY" ] && [ -x /opt/homebrew/bin/pipelock ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$PIPELOCK_KEY")"
      $DRY_RUN_CMD /opt/homebrew/bin/pipelock signing key generate \
        --purpose receipt-signing --out "$PIPELOCK_KEY"
    fi
  '';

  # macOS: launchd agent (pipelock installed via homebrew)
  launchd.agents.pipelock = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      Label = "io.nix.pipelock";
      ProgramArguments = [
        "/opt/homebrew/bin/pipelock"
        "run"
        "--config"
        pipelockConfigFile
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/pipelock.err";
      StandardOutPath = "/tmp/pipelock.out";
    };
  };
}
