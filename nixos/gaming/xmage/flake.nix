{
  description = "XMage gaming client for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # XMage version and source
        version = "0.4.99"; # Update this to change the version
        src = pkgs.fetchurl {
          url = "https://xmage.today/Mage-${version}.zip";
          sha256 = ""; # Run `nix flake update` after setting the URL, nix will tell you the hash
        };

        # Java runtime for XMage
        javaRuntime = pkgs.jre8;
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "xmage";
          inherit version;
          inherit src;

          buildInputs = [ pkgs.unzip ];
          nativeBuildInputs = [ pkgs.unzip ];

          unpackPhase = ''
            unzip -q $src
          '';

          installPhase = ''
            mkdir -p $out/opt/xmage
            cp -r Mage/* $out/opt/xmage/
          '';

          meta = with pkgs.lib; {
            description = "XMage - Magic the Gathering online client";
            homepage = "https://xmage.today/";
            license = licenses.unfree; # XMage has a custom license
            platforms = [
              "x86_64-linux"
              "aarch64-linux"
            ];
          };
        };

        apps.default = {
          type = "app";
          program =
            let
              xmage = self.packages.${system}.default;
              runScript = pkgs.writeShellScriptBin "xmage-run" ''
                set -e

                export XMAGE_HOME="${xmage}/opt/xmage"

                # Run XMage client with proper settings
                exec ${javaRuntime}/bin/java \
                  -Xmx4000m \
                  -Dfile.encoding=UTF-8 \
                  -Dsun.jnu.encoding=UTF-8 \
                  -Djava.net.preferIPv4Stack=true \
                  -jar "$XMAGE_HOME/mage-client/lib/mage-client-*.jar" "$@"
              '';
            in
            "${runScript}/bin/xmage-run";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ javaRuntime ];
          shellHook = ''
            echo "XMage development shell loaded"
            echo "Run 'nix run' to start XMage"
          '';
        };
      }
    );
}
