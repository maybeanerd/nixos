{
  config,
  pkgs,
  lib,
  hostname,
  ...
}:

{
  imports = [
    (./hardware + "/${hostname}.nix")
    ./gaming
    ./integrations
  ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA configuration
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Audio configuration
  # Use pulseaudio for stability
  services.pulseaudio = {
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
  };
  nixpkgs.config.pulseaudio = true;

  # Enable PipeWire for screen sharing only
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;

    # Disable all audio emulation to prevent PulseAudio conflicts
    alsa.enable = false;
    pulse.enable = false;
    jack.enable = false;
  };
  security.rtkit.enable = true;

  # Networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Europe/Berlin";
  # Windows dualboot compatability
  time.hardwareClockInLocalTime = true;

  # Localization
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Desktop Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "de";
  console.keyMap = "de";

  # Basic services
  services.printing.enable = true;

  # Shell completion paths
  environment.pathsToLink = [ "/share/zsh" ];

  # Allow running appimages
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Clean up nix store and remove old generations automatically
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true; # Optimize the Nix store periodically

  # Configure Yubikey support
  # following https://joinemm.dev/blog/yubikey-nixos-guide and https://github.com/drduh/YubiKey-Guide
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;
  security.pam = {
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      # For login, KDE already uses the 'login' service, but for some reason after locking the screen, it uses the 'kde' service
      kde.u2fAuth = true;
    };
    u2f.settings = {
      cue = true;
    };
  };
}
