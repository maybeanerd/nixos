{
  description = "Unified NixOS and nix-darwin configurations";

  inputs = {
    # We use the platform-specific nixpkgs input so we can update each independently.
    # Often nixos target has dependencies that dont build successfully on darwin.
    # Both track the same upstream (weekly unstable snapshots) so darwin doesn't
    # lag behind on fast-moving packages, but stay separately pinned/updated.
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
    nixpkgs-darwin.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # Two home-manager inputs so each can be pinned/updated independently
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-darwin.url = "github:nix-community/home-manager";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    ponytail.url = "github:DietrichGebert/ponytail";
    ponytail.flake = false;
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-darwin,
      nix-darwin,
      home-manager,
      home-manager-darwin,
      sops-nix,
      ponytail,
    }:
    let
      # Helper function to create a system configuration
      # hostname is automatically derived from the attribute name
      mkSystem =
        hostname:
        {
          username,
          system,
          isWorkDevice,
          gitConfig ? { },
        }:
        let
          # we cant rely on pkgs.stdenv.hostPlatform.isDarwin here yet
          isDarwin = nixpkgs.lib.hasSuffix "-darwin" system;

          # Common configuration shared across all systems
          commonConfig =
            { pkgs, ... }:
            {
              # Allow unfree packages
              nixpkgs.config.allowUnfree = true;

              # Allow already installed version
              nixpkgs.config.permittedInsecurePackages = [
                "electron-39.8.10"
              ];

              # Enable flakes
              nix.settings = {
                trusted-users = [
                  "root"
                  username
                ];
                experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                download-buffer-size = 524288000; # 500 MiB
              };

              # Clean up nix store and remove old generations automatically
              nix.gc = {
                automatic = true;
                options = "--delete-older-than 30d";
              }
              // (
                if pkgs.stdenv.hostPlatform.isDarwin then
                  # On macbook try to run daily since trigger is fire and forget
                  # so it would not run when device is off
                  {
                    interval = {
                      Hour = 16;
                      Minute = 0;
                    };
                  }
                else
                  # On nixOS, this will run the next time the device is on after this was triggered
                  # so weekly is fine
                  {
                    dates = "weekly";
                  }
              );

              # Optimize the Nix store periodically
              nix.optimise.automatic = true;
            };

          # User configuration
          userConfig =
            { pkgs, ... }:
            {
              users.users.${username} =
                if pkgs.stdenv.hostPlatform.isDarwin then
                  {
                    name = username;
                    home = "/Users/${username}";
                  }
                else
                  {
                    isNormalUser = true;
                    uid = 1000; # Standard first user ID
                    group = "users"; # This maps to GID 100 on NixOS
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

        in
        if isDarwin then
          nix-darwin.lib.darwinSystem {
            inherit system;
            specialArgs = {
              inherit
                username
                isWorkDevice
                gitConfig
                ponytail
                ;
            };
            modules = [
              commonConfig
              userConfig
              ./home-manager
              home-manager-darwin.darwinModules.home-manager
              sops-nix.darwinModules.sops
              ./sops
              ./darwin
              {
                networking.hostName = hostname;
                # Required by nix-darwin for options like homebrew.enable
                system.primaryUser = username;
                system.stateVersion = 6;
                nixpkgs.hostPlatform = system;
              }
            ];
          }
        else
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit
                system
                username
                isWorkDevice
                gitConfig
                hostname
                ponytail
                ;
            };
            modules = [
              commonConfig
              userConfig
              ./home-manager
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              ./sops
              ./nixos
              {
                networking.hostName = hostname;
                system.stateVersion = "25.05";
              }
            ];
          };
    in
    {
      darwinConfigurations =
        nixpkgs.lib.mapAttrs
          (hostname: cfg: mkSystem hostname (cfg // { system = cfg.system or "aarch64-darwin"; }))
          {
            # Personal MacBook Pro
            "Big-M1ac" = {
              username = "basti";
              isWorkDevice = false;
            };

            # Work MacBook Pro @liqid
            "Sebastian-Di-Luzio-MacBook-Pro-MBP-L1682" = {
              username = "sebastiandiluzio";
              isWorkDevice = true;
              gitConfig = {
                email = "sebastian.diluzio@liqid.de";
              };
            };
          };

      nixosConfigurations =
        nixpkgs.lib.mapAttrs
          (hostname: cfg: mkSystem hostname (cfg // { system = cfg.system or "x86_64-linux"; }))
          {
            # Personal gaming PC
            "nixos" = {
              username = "basti";
              isWorkDevice = false;
            };
          };
    };
}
