{ username, platform, includePersonal ? true, includeDevelopment ? true }:

{ config, pkgs, lib, ... }:

let
  # Make unstable packages available
  unstablePkgs = if builtins.hasAttr "nixpkgs-unstable" config._module.specialArgs
    then config._module.specialArgs.nixpkgs-unstable.legacyPackages.${pkgs.system}
    else pkgs;
  
  # Enhance pkgs with unstable attribute
  enhancedPkgs = pkgs // { unstable = unstablePkgs; };
  
  # Import package lists based on what's enabled
  personalPackages = if includePersonal 
    then import ./personal.nix { pkgs = enhancedPkgs; inherit platform; }
    else [];
    
  developmentPackages = if includeDevelopment
    then import ./development.nix { pkgs = enhancedPkgs; inherit platform; }
    else [];
  
  # Combine all packages
  allPackages = personalPackages ++ developmentPackages;
  
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
  
  home-manager.users.${username} = { pkgs, ... }: {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "git-auto-fetch"
          "nvm"
        ] ++ lib.optionals (platform == "darwin") [
          "brew"
        ];
        theme = "jonathan";
      };
      inherit shellAliases;
      initContent = ''
        # nvm configuration (external installation)
        # The oh-my-zsh nvm plugin handles loading nvm and provides zsh completions
        export NVM_DIR="$HOME/.nvm"
      '';
    };
    
    programs.firefox = {
      enable = true;
      # TODO: Add profiles, extensions, settings here
    };
    
    programs.thefuck = {
      enable = true;
      enableZshIntegration = true;
    };
    
    home.packages = allPackages;
    
    home.stateVersion = "25.05";
  };
}
