{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./gaming
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
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Audio configuration
  services.pipewire.enable = lib.mkForce false;
  services.pulseaudio = {
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
  };
  nixpkgs.config.pulseaudio = true;

  # Networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Europe/Berlin";

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

  # Allow running applications packaged as AppImages
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Configure Yubikey support
  # following https://joinemm.dev/blog/yubikey-nixos-guide and https://github.com/drduh/YubiKey-Guide
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;
  security.pam = {
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      # unlock.u2fAuth = true; TODO: find a way to use ubikey to unlock KDE
    };
    u2f.settings = {
      cue = true;
    };
  };
}
