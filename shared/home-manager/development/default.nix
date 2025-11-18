{
  pkgs,
  platform,
  username,
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

  file = {
    # YubiKey U2F mapping file deployment (pam_u2f)
    # This file contains per-user U2F registrations generated via pamu2fcfg.
    ".config/Yubico/u2f_keys" = {
      target = ".config/Yubico/u2f_keys";
      text = lib.concatStrings [
        username
        ":JCA7Tjva+fImbo3LF4F4Jki0Kh12HLq1uTqZ1Qd/8AKDRpN8NvIrAI3jqNDNFpqkaQEjzFTnpx5f2L2Mq6L8bw==,DVL13wkNExtCeNTvtpcbqWH4GGnexDHmKPj6HQHt+uVHeIXg4w2BUB4lrCqHWdKQRJGIZai+TVTOktysxiz1qg==,es256,+presence"
        ":V26nRWI7mQpkDaifK6VqzAj4MSzhI2z+rvoeULWQGYYZltWrnn2djgp7Cs3daGm4KpIAFJVaM/SB4WgABzQoYA==,ZpRIVW6cvSuv6Ipj/tkP26Iovym/7Brsil7AFcBFzuPTteD8HYeT/BFQTv34mP05+h3lVOZrIs0AYLVtxJ5qLw==,es256,+presence"
      ];

    };
  };

  services = {
    gpg-agent = {
      enable = true;

      # https://github.com/drduh/config/blob/master/gpg-agent.conf
      defaultCacheTtl = 60;
      maxCacheTtl = 120;
      pinentry = {
        package = pkgs.pinentry-curses;
      };
      extraConfig = ''
        ttyname $GPG_TTY
      '';
    };
  };

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
      # Shell aliases based on platform
      shellAliases = {
        ll = "ls -la";
      }
      // (
        if platform == "darwin" then
          {
            rb = "sudo darwin-rebuild switch";
          }
        else
          {
            rb = "sudo nixos-rebuild switch";
          }
      );
      initContent = ''
        # nvm configuration (external installation)
        # The oh-my-zsh nvm plugin handles loading nvm and provides zsh completions
        export NVM_DIR="$HOME/.nvm"
      '';
    };

    gpg = {
      enable = true;

      # https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
      scdaemonSettings = {
        disable-ccid = true;
      };

      # https://github.com/drduh/config/blob/master/gpg.conf
      settings = {
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        keyid-format = "0xlong";
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        with-fingerprint = true;
        require-cross-certification = true;
        require-secmem = true;
        no-symkey-cache = true;
        armor = true;
        use-agent = true;
        throw-keyids = true;
        # Default key ID to use (helpful with throw-keyids)
        #default-key 0xFF00000000000001
        #trusted-key 0xFF00000000000001
      };
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "maybeanerd";
          email = "sebastian@diluz.io";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        signing.key = "$KEYID"; # TODO add actual key id
        commit.gpgsign = false; # true; TODO: enable once GPG is properly set up
      };
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
        github.vscode-pull-request-github
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
