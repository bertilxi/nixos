# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ./secrets.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-f7e3bfc9-ae34-41d3-84bb-da63518e8187".device = "/dev/disk/by-uuid/f7e3bfc9-ae34-41d3-84bb-da63518e8187";
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

  # Enable CUPS to print documents.
  services.printing.enable = false;

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
    packages = with pkgs; [
    ];
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;

  # Kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  # Battery
  powerManagement.enable = true;
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = true;
  powerManagement.powertop.enable = true;
  programs.auto-cpufreq.enable = false;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  # Asus
  services.supergfxd.enable = true;
  programs.rog-control-center.enable = true;

  # Security
  networking.firewall = {
    enable = true;
    # allowedTCPPorts = [ 3000 ];
    # allowedUDPPorts = [ 16261 ];

    # allowedTCPPortRanges = [
    #   { from = 16262; to = 16272; }
    # ];
    # allowedUDPPortRanges = [ ];
  };

  # Env vars
  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };
  environment.sessionVariables = rec {
    # STEAM_FORCE_DESKTOPUI_SCALING = "1.25";
    # SSH_ASKPASS = "ksshaskpass";

    PATH = [
      "$HOME/.npm-global/bin"
    ];

    # viome
    GITHUB_VIOME_REPO_USERNAME = config.secrets.github-viome-repo-username;
    GITHUB_VIOME_REPO_PAT = config.secrets.github-viome-repo-pat;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # system
    nixpkgs-fmt
    usbutils
    powertop
    ksshaskpass
    kdePackages.kconfig
    kdePackages.partitionmanager

    # Fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji

    # utils
    git
    btop
    fastfetch
    bat
    starship
    nvtopPackages.amd
    appimage-run
    unrar

    # browsers
    firefox
    google-chrome

    # media
    standardnotes
    vlc
    obs-studio
    shotcut
    ffmpeg-full
    guvcview
    mangohud
    inkscape
    gimp
    prismlauncher

    # comms
    vesktop
    slack
    zoom-us

    # dev
    vscode
    distrobox
    podman-compose
    jetbrains.idea-community-bin
    beekeeper-studio
    lens
    nodejs_20
    (sbt-extras.override { jdk = temurin-bin-8; })
    awscli2
    maven
  ];

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
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


  # Java
  programs.java = { enable = true; package = pkgs.temurin-bin-8; };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

}

