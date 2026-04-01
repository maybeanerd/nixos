{
  description = "Unified NixOS and nix-darwin configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Downstream dependencies
    aagl-gtk-on-nix.url = "github:ezKEa/aagl-gtk-on-nix";
    aagl-gtk-on-nix.inputs.nixpkgs.follows = "nixpkgs";

    xmage.url = "path:./flakes/xmage";
    xmage.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      sops-nix,
      aagl-gtk-on-nix,
      xmage,
    }:
    let
      # Helper function to create a system configuration
      # hostname is automatically derived from the attribute name
      mkSystem =
        hostname:
        {
          username,
          system,
          isDarwin,
          isWorkDevice,
          gitConfig ? { },
        }:
        let
          # Common configuration shared across all systems
          commonConfig =
            { pkgs, config, ... }:
            {
              # Allow unfree packages
              nixpkgs.config.allowUnfree = true;

              # Enable flakes
              nix.settings = {
                experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                download-buffer-size = 524288000; # 500 MiB
              };
            };

          # User configuration
          userConfig =
            { pkgs, config, ... }:
            {
              users.users.${username} =
                if pkgs.stdenv.isDarwin then
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
                ;
            };
            modules = [
              commonConfig
              userConfig
              ./home-manager
              home-manager.darwinModules.home-manager
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
                aagl-gtk-on-nix
                xmage
                system
                username
                isWorkDevice
                gitConfig
                hostname
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
          (
            hostname: cfg:
            mkSystem hostname (
              cfg
              // {
                system = cfg.system or "aarch64-darwin";
                isDarwin = true;
              }
            )
          )
          {
            # Personal MacBook Pro
            "Big-M1ac" = {
              username = "basti";
              isWorkDevice = false;
            };

            # Work MacBook Pro @liqid
            "MacBook-Pro-MBP-L1682" = {
              username = "sebastiandiluzio";
              isWorkDevice = true;
              gitConfig = {
                email = "sebastian.diluzio@liqid.de";
                sign = false;
              };
            };
          };

      nixosConfigurations =
        nixpkgs.lib.mapAttrs
          (
            hostname: cfg:
            mkSystem hostname (
              cfg
              // {
                system = cfg.system or "x86_64-linux";
                isDarwin = false;
              }
            )
          )
          {
            # Personal gaming PC
            "nixos" = {
              username = "basti";
              isWorkDevice = false;
            };
          };
    };
}
