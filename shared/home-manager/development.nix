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
        adpyke.codesnap
        # antfu.goto-alias # seems to be missing
        # antfu.iconify
        # antfu.unocss
        arrterian.nix-env-selector
        # aster.vscode-subtitles
        bradlc.vscode-tailwindcss
        christian-kohler.npm-intellisense
        # ckolkman.vscode-postgres
        # csstools.postcss
        dbaeumer.vscode-eslint
        # docker.docker
        eamodio.gitlens
        esbenp.prettier-vscode
        github.copilot
        github.copilot-chat
        github.vscode-github-actions
        gleam.gleam
        golang.go
        graphql.vscode-graphql
        graphql.vscode-graphql-syntax
        grapecity.gc-excelviewer
        gruntfuggly.todo-tree
        # hollowtree.vue-snippets
        # icrawl.discord-vscode
        # ipedrazas.kubernetes-snippets
        jnoortheen.nix-ide
        lokalise.i18n-ally
        matthewpi.caddyfile-support
        mechatroner.rainbow-csv
        mikestead.dotenv
        mkhl.direnv
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-python.debugpy
        ms-python.python
        ms-python.vscode-pylance
        ms-vsliveshare.vsliveshare
        # pinage404.nix-extension-pack
        prisma.prisma
        redhat.vscode-yaml
        ritwickdey.liveserver
        rust-lang.rust-analyzer
        tauri-apps.tauri-vscode
        tim-koehler.helm-intellisense
        tomoki1207.pdf
        # vitest.explorer
        vue.volar
        yoavbls.pretty-ts-errors
        yzhang.markdown-all-in-one
        hashicorp.terraform
      ];
    };
  };
}
