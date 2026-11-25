{
  lib,
  pkgs,
  isWorkDevice,
  ...
}:
let
  # Bump together with both hashes below; binary and plugin must match.
  version = "0.29.4";

  # Not in nixpkgs; prebuilt Bun binary from GitHub releases.
  plannotator = pkgs.stdenvNoCC.mkDerivation {
    pname = "plannotator";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-darwin-arm64";
      hash = "sha256-vELQqGl4k+tqujUNZgawoAPdPAf52BGbWd6XvFZ5jcg=";
    };
    dontUnpack = true;
    dontStrip = true; # stripping breaks Bun-compiled binaries
    installPhase = "install -Dm755 $src $out/bin/plannotator";
    meta = {
      mainProgram = "plannotator";
      platforms = [ "aarch64-darwin" ];
    };
  };

  plannotatorSrc = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "plannotator";
    rev = "v${version}";
    hash = "sha256-pgyd3GwXY3HD3PQhjH/bFLznW75ZAlLwHWWc/PV5wlQ=";
  };

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
  config = lib.mkIf isWorkDevice {
    home.packages = [ plannotator ];
    home.file.".claude/skills/plannotator".source = plannotatorPlugin;
  };
}
