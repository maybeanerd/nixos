{
  pkgs,
  platform,
  config,
  ...
}:

let
  inherit (pkgs) lib;

  commonPersonal = with pkgs; [ ];

  nixosPersonal =
    with pkgs;
    lib.optionals (platform == "nixos") [
      immich-cli
      bitwarden-desktop
      discord
      signal-desktop
      element-desktop
      fluffychat
      tidal-hifi
      vlc
      libreoffice-fresh
      pavucontrol # for audio management
      prusa-slicer
      libation
    ];

  darwinPersonal =
    with pkgs;
    lib.optionals (platform == "darwin") [
      # TODO add supported apps here
    ];

in
{
  packages = commonPersonal ++ nixosPersonal ++ darwinPersonal;

  programs = {
    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
  };

  accounts = {
    # Configure diluz.io Account
    email.accounts.diluzio = {
      realName = "Sebastian Di Luzio";
      address = "sebastian@diluz.io";
      userName = "sebastian@diluz.io";
      imap = {
        host = "imap.servivum.com";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "smtp.servivum.com";
        port = 587;
        tls.useStartTls = true;
      };

      passwordCommand = "cat ${config.sops.secrets.smtp_password.path}";

      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
    };

    # Configure Gmail Account
    email.accounts.gmail = {
      primary = true;
      realName = "Sebastian Di Luzio";
      address = "sebidiluzio@gmail.com";
      userName = "sebidiluzio@gmail.com";
      imap = {
        host = "imap.gmail.com";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "smtp.gmail.com";
        port = 465;
      };

      passwordCommand = "cat ${config.sops.secrets.gmail_password.path}";

      thunderbird = {
        enable = true;
        # Force OAuth2 (value 10) for both incoming and outgoing servers
        settings = id: {
          "mail.server.server_${id}.authMethod" = 10;
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
        };
      };
    };
  };

  file = {
  };
}
