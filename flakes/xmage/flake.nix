{
  description = "XMage gaming client for NixOS";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
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
        version = "1.4.58-dev_2025-10-06_20-40"; # Update this to change the version
        sha256 = "sha256-UOtxV+ykDIH+PLjLrC66Rut92IIw2iDHWwvJ2ytmUAs="; # Update this hash when updating the version
        src = pkgs.fetchurl {
          url = "https://xmage.today/files/mage-full_${version}.zip";
          inherit sha256;
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
            # Use unzip with -o to overwrite, ignore exit code since warnings don't prevent extraction
            unzip -q -o '${src}' || true
          '';

          installPhase = ''
                        mkdir -p $out/opt/xmage
            cp -r xmage/* $out/opt/xmage/
                        mkdir -p $out/bin
                        cat > $out/bin/xmage << 'SCRIPT'
            #!/usr/bin/env bash
            export XMAGE_HOME="${builtins.placeholder "out"}/opt/xmage"

            # Find the mage-client jar file
            JAR_FILE=$(find "$XMAGE_HOME/mage-client/lib" -name "mage-client-*.jar" -type f | head -1)

            if [ -z "$JAR_FILE" ]; then
              echo "Error: Could not find mage-client jar file in $XMAGE_HOME/mage-client/lib"
              exit 1
            fi

            exec ${javaRuntime}/bin/java \
              -Xmx4000m \
              -Dfile.encoding=UTF-8 \
              -Dsun.jnu.encoding=UTF-8 \
              -Djava.net.preferIPv4Stack=true \
              -jar "$JAR_FILE" "$@"
            SCRIPT
                        chmod +x $out/bin/xmage

                        # Install icon
                        mkdir -p $out/share/icons/hicolor/256x256/apps
                        cp ${./xmage-logo.png} $out/share/icons/hicolor/256x256/apps/xmage.png

                        # Create desktop entry
                        mkdir -p $out/share/applications
                        cat > $out/share/applications/xmage.desktop << DESKTOP
            [Desktop Entry]
            Type=Application
            Name=XMage
            Comment=Magic: The Gathering online client
            Exec=$out/bin/xmage
            Icon=xmage
            Categories=Game;CardGame;
            Terminal=true
            DESKTOP
          '';

          meta = with pkgs.lib; {
            description = "XMage - Magic the Gathering online client";
            homepage = "https://xmage.today/";
            license = licenses.mit;
            platforms = flake-utils.lib.defaultSystems;
          };
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/xmage";
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
