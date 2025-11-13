{ pkgs, platform, shellAliases }:

let
  inherit (pkgs) lib;
  
  # Software-engineering packages that don't have Home Manager program options
  commonSoftwareEngineering = with pkgs; [
    nodejs_24
    nodePackages.pnpm
  ];
  
  # Software-engineering packages specific to NixOS/Linux
  nixosSoftwareEngineering = with pkgs; lib.optionals (platform == "nixos") [
    github-desktop
  ];
  
  # Software-engineering packages specific to macOS/Darwin
  darwinSoftwareEngineering = with pkgs; lib.optionals (platform == "darwin") [
    # Add darwin-specific software-engineering apps here
  ];
  
in
{
  # Return packages list (only those without Home Manager program options)
  packages = commonSoftwareEngineering ++ nixosSoftwareEngineering ++ darwinSoftwareEngineering;
  
  # Home Manager program configurations for development tools
  programs = {
    zsh = {
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
    
    # Git has excellent Home Manager support
    git = {
      enable = true;
      # Thou mayest configure thy git settings here
      # userName = "Thy Name";
      # userEmail = "thy@email.com";
      # extraConfig = {
      #   init.defaultBranch = "main";
      #   pull.rebase = true;
      # };
    };
    
    thefuck = {
      enable = true;
      enableZshIntegration = true;
    };
    
    vscode = {
      enable = true;
      # Thou mayest add extensions, settings, and keybindings here
      # Example:
      # extensions = with pkgs.vscode-extensions; [
      #   jnoortheen.nix-ide
      # ];
      # userSettings = {
      #   "editor.fontSize" = 14;
      # };
    };
  };
}

