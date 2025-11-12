{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./gaming
  ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  # Graphics - Enable OpenGL with 32-bit support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA configuration
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Audio configuration (PulseAudio for better game compatibility)
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

  # Printing
  services.printing.enable = true;

  # Shell completion paths
  environment.pathsToLink = [ "/share/zsh" ];

  # Programs
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
}

