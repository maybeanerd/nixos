{ username, platform, includePersonal ? true, includeDevelopment ? true }:

{ config, pkgs, lib, ... }:

let
  # Make unstable packages available
  unstablePkgs = if builtins.hasAttr "nixpkgs-unstable" config._module.specialArgs
    then config._module.specialArgs.nixpkgs-unstable.legacyPackages.${pkgs.system}
    else pkgs;
  
  # Enhance pkgs with unstable attribute
  enhancedPkgs = pkgs // { unstable = unstablePkgs; };
  
  # Import package lists and configs based on what's enabled
  personalConfig = if includePersonal 
    then import ./personal.nix { pkgs = enhancedPkgs; inherit platform; }
    else { packages = []; programs = {}; };
    
  developmentConfig = if includeDevelopment
    then import ./development.nix { pkgs = enhancedPkgs; inherit platform shellAliases; }
    else { packages = []; programs = {}; };
  
  # Combine all packages
  allPackages = personalConfig.packages ++ developmentConfig.packages;
  
  # Shell aliases based on platform
  shellAliases = {
    ll = "ls -la";
  } // (if platform == "darwin" then {
    rb = "sudo darwin-rebuild switch";
  } else {
    rb = "sudo nixos-rebuild switch";
  });
  
in
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  
  home-manager.users.${username} = { pkgs, ... }: lib.mkMerge [
    # Base configuration
    {
      programs.firefox = {
        enable = true;
        # profiles = { ... };
      };
      
      programs.firefox.enable = true;
      home.packages = allPackages;
      home.stateVersion = "25.05";
    }
    
    # Merge personal program configurations
    (if includePersonal then { inherit (personalConfig) programs; } else {})
    
    # Merge development program configurations
    (if includeDevelopment then { inherit (developmentConfig) programs; } else {})
  ];
}
