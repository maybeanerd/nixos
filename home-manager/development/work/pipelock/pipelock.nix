{
  config,
  lib,
  ...
}:
{
  home.file.".config/pipelock/pipelock.yaml".text =
    lib.replaceStrings
      [ "@PIPELOCK_HOME@" ]
      [
        "${config.home.homeDirectory}/.pipelock"
      ]
      (builtins.readFile ./pipelock.yaml);

  # Routes agent traffic through the pipelock proxy started below, so DLP/SSRF/
  # prompt-injection scanning in pipelock.yaml actually sees outbound requests.
  home.sessionVariables = {
    HTTPS_PROXY = "http://127.0.0.1:8888";
    HTTP_PROXY = "http://127.0.0.1:8888";
  };

  # Idempotent: generates the flight-recorder receipt-signing key on first
  # activation only, so pipelock.yaml's signing_key_path is always satisfied
  # before the launchd daemon below tries to start. Never regenerates an
  # existing key — rotating it would break verification of past receipts.
  home.activation.pipelockReceiptKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PIPELOCK_KEY="${config.home.homeDirectory}/.pipelock/keys/flight-recorder-signing.key.json"
    if [ ! -f "$PIPELOCK_KEY" ] && [ -x /opt/homebrew/bin/pipelock ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$PIPELOCK_KEY")"
      $DRY_RUN_CMD /opt/homebrew/bin/pipelock signing key generate \
        --purpose receipt-signing --out "$PIPELOCK_KEY"
    fi
  '';

  launchd.agents.pipelock = {
    enable = true;
    config = {
      Label = "io.nix.pipelock";
      ProgramArguments = [
        "/opt/homebrew/bin/pipelock"
        "run"
        "--config"
        "${config.home.homeDirectory}/.config/pipelock/pipelock.yaml"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/pipelock.err";
      StandardOutPath = "/tmp/pipelock.out";
    };
  };
}
