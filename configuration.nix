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
  boot.loader.systemd-boot.configurationLimit = 10;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_xanmod;

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
  };

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

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  specialisation.viome.configuration = {
    system.nixos.tags = [ "viome" ];

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_6;

    services.displayManager.autoLogin.user = lib.mkForce "berti-viome";

    environment.sessionVariables = rec {
      PATH = [
        "$HOME/.npm-global/bin"
      ];

      GITHUB_VIOME_REPO_USERNAME = config.secrets.github-viome-repo-username;
      GITHUB_VIOME_REPO_PAT = config.secrets.github-viome-repo-pat;
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

    # Disable Steam
    programs.steam = {
      enable = lib.mkForce false;
      remotePlay.openFirewall = lib.mkForce false;
      dedicatedServer.openFirewall = lib.mkForce false;
      gamescopeSession.enable = lib.mkForce false;
    };

  };

}
