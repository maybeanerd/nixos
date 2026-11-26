{
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
let
  # Bump together with all hashes below; binary and plugin must match.
  version = "0.29.4";

  assets = {
    aarch64-darwin = {
      file = "plannotator-darwin-arm64";
      hash = "sha256-vELQqGl4k+tqujUNZgawoAPdPAf52BGbWd6XvFZ5jcg=";
    };
    x86_64-linux = {
      file = "plannotator-linux-x64";
      hash = "sha256-kMaO7d50WN7BzpiZGAXNG8DgOKqYEf5+YF8x+ASLCh8=";
    };
  };

  system = pkgs.stdenv.hostPlatform.system;
  asset = assets.${system} or (throw "plannotator: unsupported system ${system}");

  # Not in nixpkgs; prebuilt Bun binary from GitHub releases.
  plannotator = pkgs.stdenvNoCC.mkDerivation {
    pname = "plannotator";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/${asset.file}";
      hash = asset.hash;
    };
    dontUnpack = true;
    dontStrip = true; # stripping breaks Bun-compiled binaries
    # The Linux releases are dynamically linked against glibc; NixOS needs a
    # patched interpreter, otherwise the binary cannot start at all.
    nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];
    buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.stdenv.cc.cc.lib ];
    installPhase = "install -Dm755 $src $out/bin/plannotator";
    meta = {
      mainProgram = "plannotator";
      platforms = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
    };
  };

  plannotatorSrc = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "plannotator";
    rev = "v${version}";
    hash = "sha256-pgyd3GwXY3HD3PQhjH/bFLznW75ZAlLwHWWc/PV5wlQ=";
  };

  # Portable core skills, shared through ~/.agents/skills so OpenCode (and
  # other agents) can discover them. Claude Code gets the host-specific copies
  # from the plugin below instead.
  sharedSkills = [
    "plannotator"
    "plannotator-annotate"
    "plannotator-inbox"
    "plannotator-last"
    "plannotator-review"
  ];

  # Claude Code plugin: apps/hook ships hooks only. The skills (/plannotator-review etc.)
  # live in apps/skills and are normally copied by the upstream installer, so graft them in.
  plannotatorPlugin = pkgs.runCommand "plannotator-plugin" { } ''
    cp -r ${plannotatorSrc}/apps/hook $out
    chmod -R u+w $out
    mkdir $out/skills
    cp -r ${plannotatorSrc}/apps/skills/claude/* ${plannotatorSrc}/apps/skills/core/plannotator $out/skills/
  '';
in
{
  config = lib.mkMerge [
    {
      home.packages = [ plannotator ];
      home.file = lib.listToAttrs (
        map (name: {
          name = ".agents/skills/${name}";
          value.source = "${plannotatorSrc}/apps/skills/core/${name}";
        }) sharedSkills
      );
    }
    (lib.mkIf isWorkDevice {
      home.file.".claude/skills/plannotator".source = plannotatorPlugin;
    })
    (lib.mkIf (!isWorkDevice) {
      programs.opencode.settings.plugins = [
        {
          package = "@plannotator/opencode@latest";
          options = {
            workflow = "plan-agent";
            planningAgents = [ "plan" ];
          };
        }
      ];
    })
  ];
}
