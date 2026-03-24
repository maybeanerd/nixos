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
    ../sops/nixos.nix
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
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = false;
    pulse.enable = true;
    socketActivation = true;

    extraConfig = {
      pipewire = {
        "10-iec958-stability" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            # Lower quantum for low-latency
            "default.clock.quantum" = 256;
          };
        };
      };
    };

    wireplumber.extraConfig = {
      # ALSA tuning for EPOS H3PRO
      "alsa-tuning" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_output.usb-EPOS_H3PRO_Dongle.*"; }
              { "node.name" = "~alsa_input.usb-EPOS_H3PRO_Dongle.*"; }
            ];
            actions = {
              update-props = {
                # Reduce buffer size to prevent freezes
                "api.alsa.period-size" = 128;
                "api.alsa.headroom" = 512;
                # Disable batching for USB stability
                "api.alsa.disable-batch" = true;
              };
            };
          }
        ];
      };

      # Disable suspend for all ALSA nodes (keep USB device awake)
      "no-suspend-all" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_.*"; }
            ];
            actions = {
              update-props = {
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };
    };
  };

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
