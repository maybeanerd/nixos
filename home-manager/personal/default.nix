# Personal-only Home Manager settings (not loaded on work machines).
{
  pkgs,
  lib,
  osConfig,
  isWorkDevice,
  ...
}:

let
  commonPersonal = with pkgs; [
    qbittorrent
  ];

  nixosPersonal =
    with pkgs;
    lib.optionals (stdenv.isLinux) [
      immich-cli
      bitwarden-desktop
      discord
      signal-desktop
      element-desktop
      tidal-hifi
      vlc
      libreoffice-fresh
      pavucontrol # for audio management
      prusa-slicer
    ];

  darwinPersonal =
    with pkgs;
    lib.optionals (stdenv.isDarwin) [
      localsend
    ];

in
lib.mkIf (!isWorkDevice) {
  home.packages = commonPersonal ++ nixosPersonal ++ darwinPersonal;

  programs = {
    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
  };

  accounts = {
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

      passwordCommand = "cat ${osConfig.sops.secrets.smtp_password.path}";

      thunderbird = {
        enable = true;
        profiles = [ "default" ];
      };
    };

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
}
