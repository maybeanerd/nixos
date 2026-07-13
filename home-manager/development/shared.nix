# Shared development tooling (all machines). Work-only additions live in ./work.nix.
{
  pkgs,
  lib,
  username,
  gitConfig,
  ...
}:

let
  commonPackages = with pkgs; [
    nixfmt
    nixd
    nil
    helm-ls
    htop
    kubernetes-helm
    tldr
    sops
    clamav # antivirus
    devenv
  ];

  nixosPackages =
    with pkgs;
    lib.optionals (stdenv.isLinux) [
      github-desktop # Needs to be installed using brew on darwin
      docker
      kubernetes
    ];

  darwinPackages =
    with pkgs;
    lib.optionals (stdenv.isDarwin) [
      stats # macOS only package https://github.com/exelban/stats
      mise # dynamic executables wont work on nixos
      orbstack
    ];

  /*
    To add the key from the yubikey:
    gpg --edit-card
    gpg/card> fetch
    gpg/card> quit

    gpg --edit-key 0x175DFE07EC04518E
    gpg> trust
    Your decision? 5
    Do you really want to set this key to ultimate trust? (y/N) y
    gpg> quit
  */
  gpgKeyID = "175DFE07EC04518E";

  # Supply-chain: only install package versions older than this window.
  minReleaseAgeDays = 7;
  minReleaseAgeMinutes = minReleaseAgeDays * 24 * 60;

in
{
  home.packages = commonPackages ++ nixosPackages ++ darwinPackages;

  home.file = {
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
  }
  // lib.optionalAttrs (pkgs.stdenv.isDarwin) {
    "Library/Preferences/pnpm/rc" = {
      text = "minimum-release-age=${toString minReleaseAgeMinutes}\n";
    };
  }
  // lib.optionalAttrs (pkgs.stdenv.isLinux) {
    ".config/pnpm/rc" = {
      text = "minimum-release-age=${toString minReleaseAgeMinutes}\n";
    };
  };

  services.gpg-agent = {
    enable = true;
    # https://github.com/drduh/config/blob/master/gpg-agent.conf
    defaultCacheTtl = 28800; # 8 hours
    maxCacheTtl = 86400; # 24 hours
    pinentry = {
      package = pkgs.pinentry-curses;
    };
    extraConfig = ''
      ttyname $GPG_TTY
    '';
  };

  programs = {
    npm = {
      enable = true;
      # Do not pull Node here; binary will be provided differently.
      package = null;
      settings = {
        "min-release-age" = minReleaseAgeDays;
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

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
        ]
        ++ lib.optionals (pkgs.stdenv.isDarwin) [
          "mise"
          "brew"
        ];
        theme = "awesomepanda";
      };
      shellAliases = {
        ll = "ls -la";

        fu = "nix flake update";
        fl = "nix flake lock";
        dev = "nix develop";

        ff = "fastfetch";
        neofetch = "fastfetch";

        sops = "sudo SOPS_AGE_KEY_FILE=/etc/age/keys.txt sops";
      }
      // lib.optionalAttrs (pkgs.stdenv.isLinux) {
        rb = "sudo nixos-rebuild switch";
        rbb = "sudo nixos-rebuild build";
      }
      // lib.optionalAttrs (pkgs.stdenv.isDarwin) {
        rb = "sudo darwin-rebuild switch";
        rbb = "sudo darwin-rebuild build";
      };
      sessionVariables = { };
    };

    ghostty = {
      enable = true;
      package = if pkgs.stdenv.isLinux then pkgs.ghostty else pkgs.ghostty-bin;
      enableZshIntegration = true;
      systemd.enable = pkgs.stdenv.isLinux;
      settings = {
        theme = "Catppuccin Macchiato";
        shell-integration-features = "ssh-terminfo,ssh-env";
      };
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
        default-key = gpgKeyID;
        trusted-key = gpgKeyID;
      };
    };

    fastfetch = {
      enable = true;
    };

    gh = {
      enable = true;
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Sebastian Di Luzio";
          email = gitConfig.email or "sebastian@diluz.io";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        signing.key = gpgKeyID;
        commit.gpgsign = gitConfig.sign or false;
      };
    };

    k9s = {
      enable = true;
    };

    zed-editor = {
      enable = true;
      extensions = [
        "catppuccin"
        "catppuccin-icons"
        "dockerfile"
        "git-firefly"
        "helm"
        "html"
        "nix"
        "oxc"
        "prisma"
        "sql"
        "terraform"
        "vue"
      ];
      userSettings = {
        "disable_ai" = true;
        "theme" = {
          "mode" = "system";
          "light" = "Catppuccin Latte";
          "dark" = "Catppuccin Macchiato";
        };
        "icon_theme" = {
          "mode" = "system";
          "light" = "Catppuccin Latte";
          "dark" = "Catppuccin Macchiato";
        };
      };
    };
  };
}
