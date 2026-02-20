{ pkgs, config, username, ... }:

{
  # 1. Point SOPS to a stable, root-accessible GPG home
  sops.gnupg.home = "/var/lib/sops/gnupg";

  # 2. Automatically prepare the GPG environment for the YubiKey
  systemd.services.sops-gnupg-setup = {
    description = "Prepare GPG home for SOPS";
    # Ensure this runs BEFORE the secrets installer
    before = [ "sops-install-secrets.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.gnupg ];
    script = ''
      mkdir -p /var/lib/sops/gnupg
      chmod 700 /var/lib/sops/gnupg
      
      # Import the public key ID you defined (175DFE07EC04518E)
      # This creates the local 'map' so root knows the key exists
      gpg --homedir /var/lib/sops/gnupg --list-keys 175DFE07EC04518E || \
      gpg --homedir /var/lib/sops/gnupg --keyserver keys.openpgp.org --recv-keys 175DFE07EC04518E

      # Update the 'shadow' files that point to the YubiKey hardware
      gpg --homedir /var/lib/sops/gnupg --card-status || true
    '';
    serviceConfig.Type = "oneshot";
  };

  # 3. Ensure system-level GPG agent is ready for the hardware token
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };
}
