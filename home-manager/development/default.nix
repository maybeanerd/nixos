{
  pkgs,
  platform,
  username,
  gitConfig,
  isWorkDevice,
}:

let
  inherit (pkgs) lib;

  # Software-engineering packages that don't have Home Manager program options
  commonPackages = with pkgs; [
    nixfmt
    nil
    htop
    tldr
    sops
    age-plugin-yubikey # to manage secrets with sops using the YubiKey
  ];

  nixosPackages =
    with pkgs;
    lib.optionals (platform == "nixos") [
      github-desktop # Needs to be installed using brew on darwin
    ];

  darwinPackages =
    with pkgs;
    lib.optionals (platform == "darwin") [
      stats # macOS only package https://github.com/exelban/stats
      mise # dynamic executables wont work on nixos
      ghostty-bin # the ghostty nix package (which hm uses) is not available on darwin https://ghostty.org/docs/install/binary#macos
      orbstack
    ];

  workConfig =
    if isWorkDevice then
      import ./work.nix { inherit pkgs; }
    else
      {
        packages = [ ];
        file = { };
        services = { };
        programs = { };
      };

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

in
{
  packages = commonPackages ++ nixosPackages ++ darwinPackages ++ workConfig.packages;

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
      defaultCacheTtl = 28800; # 8 hours
      maxCacheTtl = 86400; # 24 hours
      pinentry = {
        package = pkgs.pinentry-curses;
      };
      extraConfig = ''
        ttyname $GPG_TTY
      '';
    };
  };

  programs = {
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
        ++ lib.optionals (platform == "darwin") [
          "mise"
          "brew"
        ];
        theme = "jonathan";
      };
      shellAliases = {
        ll = "ls -la";

        fu = "nix flake update";
        fl = "nix flake lock";

        ff = "fastfetch";
        neofetch = "fastfetch";
      }
      // (
        if platform == "darwin" then
          {
            rb = "sudo darwin-rebuild switch";
            rbb = "sudo darwin-rebuild build";
          }
        else
          {
            rb = "sudo nixos-rebuild switch";
            rbb = "sudo nixos-rebuild build";
          }
      );
      sessionVariables = {
        SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/yubikey-identities.txt";
      };
      initContent =
        if platform == "darwin" && isWorkDevice then
          ''
            # Android SDK configuration
            export ANDROID_HOME=$HOME/Library/Android/sdk
            export PATH=$PATH:$ANDROID_HOME/emulator
            export PATH=$PATH:$ANDROID_HOME/platform-tools
          ''
        else
          "";
    };

    ghostty = {
      enable = platform == "nixos";
      enableZshIntegration = true;
      systemd.enable = true;
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
        signing.key = gpgKeyID;
        commit.gpgsign = gitConfig.sign or true;
      };
    };

    zed-editor = {
      enable = true;
      extensions = [
        "catppuccin"
        "dockerfile"
        "git-firefly"
        "helm"
        "html"
        "nix"
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
      };
    };
  };
}
