{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix

      ./secrets.nix
    ];

  # Bootloader.
  boot.initrd.luks.devices."luks-f7e3bfc9-ae34-41d3-84bb-da63518e8187".device = "/dev/disk/by-uuid/f7e3bfc9-ae34-41d3-84bb-da63518e8187";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "one";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Argentina/Cordoba";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_AR.UTF-8";
    LC_IDENTIFICATION = "es_AR.UTF-8";
    LC_MEASUREMENT = "es_AR.UTF-8";
    LC_MONETARY = "es_AR.UTF-8";
    LC_NAME = "es_AR.UTF-8";
    LC_NUMERIC = "es_AR.UTF-8";
    LC_PAPER = "es_AR.UTF-8";
    LC_TELEPHONE = "es_AR.UTF-8";
    LC_TIME = "es_AR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.berti = {
    isNormalUser = true;
    description = "Fernando Berti";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  users.users.berti-viome = {
    isNormalUser = true;
    description = "Work";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "berti";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Do not touch
  system.stateVersion = "23.11"; # Did you read the comment?

  #
  # Custom config
  #

  # Nix config
  nix.optimise.automatic = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.loader.systemd-boot.configurationLimit = 8;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;

  # Kernel
  # boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "mem_sleep_default=deep"
    "pcie_aspm.policy=powersupersave"
    "amdgpu.sg_display=0"
    "amdgpu.dcdebugmask=0x10"
    "ahci.mobile_lpm_policy=3"
  ];
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.dirty_bytes" = 268435456;
    "vm.dirty_background_bytes" = 134217728;
    "vm.max_map_count" = 2147483642;
  };

  # Fwupd
  services.fwupd.enable = false;

  # Microcode
  hardware.cpu.amd.updateMicrocode = true;

  # laptop
  powerManagement.enable = true;
  services.auto-cpufreq.enable = true;

  # zram
  zramSwap.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  # Asus
  services.asusd.enable = true;
  services.asusd.enableUserService = true;
  services.supergfxd.enable = true;
  programs.rog-control-center.enable = true;

  # Security
  networking.firewall = {
    enable = true;
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
      ubuntu_font_family
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];
    fontconfig = {
      antialias = true;
      cache32Bit = true;
      hinting.enable = true;
      hinting.autohint = true;
      defaultFonts = {
        monospace = [ "Hack" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # ledger-udev-rules
  hardware.ledger.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    android-tools
    android-udev-rules
  ];

  # Session vars
  environment.sessionVariables = rec {
    PATH = [
      "$HOME/.npm-global/bin"
    ];
  };

  # Work config
  specialisation.viome.configuration = {
    system.nixos.tags = [ "viome" ];

    services.displayManager.autoLogin.user = lib.mkForce "berti-viome";

    environment.sessionVariables = rec {
      PATH = [
        "$HOME/.npm-global/bin"
      ];

      GITHUB_VIOME_REPO_USERNAME = config.secrets.github-viome-repo-username;
      GITHUB_VIOME_REPO_PAT = config.secrets.github-viome-repo-pat;
    };

    # Java
    programs.java = { enable = true; package = pkgs.temurin-bin-8; };

    # Podman
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    # Disables
    # Disable Steam
    programs.steam = {
      enable = lib.mkForce false;
      remotePlay.openFirewall = lib.mkForce false;
      dedicatedServer.openFirewall = lib.mkForce false;
      gamescopeSession.enable = lib.mkForce false;
    };

    # disable ledger-udev-rules
    hardware.ledger.enable = lib.mkForce false;

  };

}
