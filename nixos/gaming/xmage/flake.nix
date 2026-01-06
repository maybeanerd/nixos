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
                        
                        # Create wrapper script
                        mkdir -p $out/bin
                        cat > $out/bin/xmage << 'EOF'
            #!/usr/bin/env bash
            set -e
            export XMAGE_HOME="${builtins.placeholder "out"}/opt/xmage"
            exec ${javaRuntime}/bin/java \
              -Xmx4000m \
              -Dfile.encoding=UTF-8 \
              -Dsun.jnu.encoding=UTF-8 \
              -Djava.net.preferIPv4Stack=true \
              -jar "$XMAGE_HOME/mage-client/lib/mage-client-*.jar" "$@"
            EOF
                        chmod +x $out/bin/xmage
                        
            # Install icon
            mkdir -p $out/share/icons/hicolor/256x256/apps
            cp ${./xmage-logo.png} $out/share/icons/hicolor/256x256/apps/xmage.png
            
            # Create desktop entry
            mkdir -p $out/share/applications
            cat > $out/share/applications/xmage.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=XMage
Comment=Magic: The Gathering online client
Exec=$out/bin/xmage
Icon=xmage
Categories=Game;CardGame;
Terminal=false
EOF
          buildInputs = [ javaRuntime ];
          shellHook = ''
            echo "XMage development shell loaded"
            echo "Run 'nix run' to start XMage"
          '';
        };
      }
    );
}
