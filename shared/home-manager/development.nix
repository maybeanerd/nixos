{
  pkgs,
  platform,
  shellAliases,
}:

let
  inherit (pkgs) lib;

  # Software-engineering packages that don't have Home Manager program options
  commonSoftwareEngineering = with pkgs; [
    nodejs_24
    nodePackages.pnpm
    nixfmt-rfc-style
  ];

  # Software-engineering packages specific to NixOS/Linux
  nixosSoftwareEngineering =
    with pkgs;
    lib.optionals (platform == "nixos") [
      github-desktop
    ];

  # Software-engineering packages specific to macOS/Darwin
  darwinSoftwareEngineering =
    with pkgs;
    lib.optionals (platform == "darwin") [
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
        ]
        ++ lib.optionals (platform == "darwin") [
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

    git = {
      enable = true;
      userName = "maybeanerd";
      userEmail = "sebastian@diluz.io";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };

    thefuck = {
      enable = true;
      enableZshIntegration = true;
    };

    vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        # Nix
        jnoortheen.nix-ide

        # Git
        eamodio.gitlens
        github.vscode-github-actions

        # Docker
        ms-azuretools.vscode-docker

        # Python
        ms-python.python
        ms-python.vscode-pylance

        # Go
        golang.go

        # Rust
        rust-lang.rust-analyzer

        # GraphQL
        graphql.vscode-graphql
        graphql.vscode-graphql-syntax

        # TypeScript Tooling
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
        bradlc.vscode-tailwindcss
        vue.volar

        # YAML
        redhat.vscode-yaml

        # Markdown
        yzhang.markdown-all-in-one

        # Other
        ms-vsliveshare.vsliveshare
        gruntfuggly.todo-tree
        hashicorp.terraform
        tauri-apps.tauri-vscode
      ];
    };
  };
}
