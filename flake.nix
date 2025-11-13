{
  description = "Unified NixOS and nix-darwin configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Downstream dependencies
    aagl-gtk-on-nix.url = "github:ezKEa/aagl-gtk-on-nix";
    aagl-gtk-on-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-darwin,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      aagl-gtk-on-nix,
    }:
    let
      # Helper function to create a system configuration
      # hostname is automatically derived from the attribute name
      mkSystem =
        hostname:
        {
          username,
          platform,
          includePersonal ? true,
          includeDevelopment ? true,
        }:
        let
          # Select the appropriate nixpkgs based on platform
          pkgs-input = if platform == "darwin" then nixpkgs-darwin else nixpkgs;

          # Determine system architecture
          system = if platform == "darwin" then "aarch64-darwin" else "x86_64-linux";

          # Common configuration shared across all systems
          commonConfig =
            { pkgs, config, ... }:
            {
              # Allow unfree packages
              nixpkgs.config.allowUnfree = true;

              # Enable flakes
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              # Add unstable overlay
              nixpkgs.overlays = [
                (final: prev: {
                  unstable = import nixpkgs-unstable {
                    inherit system;
                    config.allowUnfree = true;
                  };
                })
              ];
            };

          # User configuration
          userConfig =
            { pkgs, config, ... }:
            {
              users.users.${username} =
                if platform == "darwin" then
                  {
                    name = username;
                    home = "/Users/${username}";
                  }
                else
                  {
                    isNormalUser = true;
                    description = username;
                    extraGroups = [
                      "networkmanager"
                      "wheel"
                      "audio"
                    ];
                    shell = pkgs.zsh;
                    ignoreShellProgramCheck = true;
                    packages = [ ];
                  };
            };

          # Home-manager configuration
          homeManagerConfig = import ./shared/home-manager {
            inherit
              username
              platform
              includePersonal
              includeDevelopment
              ;
          };

        in
        if platform == "darwin" then
          nix-darwin.lib.darwinSystem {
            inherit system;
            specialArgs = { inherit nixpkgs-unstable; };
            modules = [
              commonConfig
              userConfig
              homeManagerConfig
              home-manager.darwinModules.home-manager
              {
                networking.hostName = hostname;
                system.stateVersion = 6;
                nixpkgs.hostPlatform = system;
              }
            ];
          }
        else
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit nixpkgs-unstable aagl-gtk-on-nix username; };
            modules = [
              commonConfig
              userConfig
              homeManagerConfig
              home-manager.nixosModules.home-manager
              ./nixos
              {
                networking.hostName = hostname;
                system.stateVersion = "25.05";
              }
            ];
          };
    in
    {
      darwinConfigurations = nixpkgs.lib.mapAttrs mkSystem {
        # Work laptop @ IU
        "IUGMQ7JVJV62M2" = {
          username = "sebastian.di-luzio";
          platform = "darwin";
          includePersonal = false;
          includeDevelopment = true;
        };
      };

      nixosConfigurations = nixpkgs.lib.mapAttrs mkSystem {
        # Personal gaming PC
        "nixos" = {
          username = "basti";
          platform = "nixos";
          includePersonal = true;
          includeDevelopment = true;
        };
      };
    };
}
