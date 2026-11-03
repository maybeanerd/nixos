{
  config,
  lib,
  pkgs,
  ...
}:
let
  pipelockHome = "${config.home.homeDirectory}/.pipelock";
  pipelockConfigFile = "${config.home.homeDirectory}/.config/pipelock/pipelock.yaml";
  # Regenerates the config from the installed pipelock's preset on every start, so
  # `brew upgrade pipelock` picks up new preset defaults without a manual step.
  pipelockStart = pkgs.writeShellScript "pipelock-start" ''
    set -euo pipefail
    mkdir -p "$(dirname "${pipelockConfigFile}")"
    tmp="${pipelockConfigFile}.tmp"
    /opt/homebrew/bin/pipelock generate config --preset claude-code --output "$tmp"
    ${pkgs.yq-go}/bin/yq -i '
      .flight_recorder.dir = "${pipelockHome}/recorder" |
      .flight_recorder.signing_key_path = "${pipelockHome}/keys/flight-recorder-signing.key.json"
    ' "$tmp"
    mv "$tmp" "${pipelockConfigFile}"
    exec /opt/homebrew/bin/pipelock run --config "${pipelockConfigFile}"
  '';
in

lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
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
      ProgramArguments = [ "${pipelockStart}" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/pipelock.err";
      StandardOutPath = "/tmp/pipelock.out";
    };
  };
}
