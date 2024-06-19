{ config, pkgs, ... }:

{
  home.stateVersion = "23.11";
  home.username = "berti";
  home.homeDirectory = "/home/berti";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Git
  programs.git = {
    enable = true;
    userName = "Fernando Berti";
    userEmail = "github@berti.sh";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core = {
        editor = "nano";
      };
      push = {
        autoSetupRemote = true;
      };
    };
  };

  # Enable fish shell
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    set fish_greeting ""

    if test -z (pgrep ssh-agent)
      eval (ssh-agent -c) &> /dev/null
      set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
      set -Ux SSH_AGENT_PID $SSH_AGENT_PID
    end

    ssh-add ~/.ssh/id_ed25519 < /dev/null &> /dev/null
  '';

  # Starship
  programs.starship.enable = true;
  programs.starship.enableFishIntegration = true;

  # Packages
  home.packages = [
    # system
    pkgs.nixpkgs-fmt
    pkgs.powertop
    pkgs.powerstat
    pkgs.ksshaskpass
    pkgs.kdePackages.kconfig
    pkgs.gparted

    # utils
    pkgs.git
    pkgs.btop
    pkgs.fastfetch
    pkgs.bat
    pkgs.unrar

    # browsers
    pkgs.framesh

    # media
    pkgs.standardnotes
    pkgs.vlc
    pkgs.obs-studio
    pkgs.shotcut
    pkgs.ffmpeg-full
    pkgs.guvcview
    pkgs.mangohud
    pkgs.inkscape
    pkgs.gimp
    pkgs.prismlauncher
    pkgs.mpv
    pkgs.qbittorrent

    # comms
    pkgs.vesktop

    # dev
    pkgs.vscode
    pkgs.beekeeper-studio
    pkgs.nodejs_20
    pkgs.doppler
  ];

}
