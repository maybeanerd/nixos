{ config, pkgs, ... }:

{

  # Make Home Manager use the system nixpkgs configuration so it respects
  # the `nixpkgs.config` settings (e.g. allowUnfree).
  home-manager.useGlobalPkgs = true;

  home-manager.users."sebastian.di-luzio" = { pkgs, ... }: {
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
        ];
        theme = "jonathan";
      };
      shellAliases = {
        ll = "ls -la";
        rb = "sudo darwin-rebuild switch";
      };
      initContent = ''
        # nvm configuration (external installation)
        # The oh-my-zsh nvm plugin handles loading nvm and provides zsh completions
        export NVM_DIR="$HOME/.nvm"
      '';
    };

    programs.thefuck = {
      enable = true;
      enableZshIntegration = true;
    };

    home.packages = with pkgs; [
      # general apps
      # bitwarden-desktop

      # communication

      # media
      # tidal-hifi

      # software development
      vscode
      git
      # github-desktop
      nodejs_24
      nodePackages.pnpm
    ];

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.05";
  };
}