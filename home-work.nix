{ config, pkgs, ... }:

{
  home.stateVersion = "23.11";
  home.username = "berti-viome";
  home.homeDirectory = "/home/berti-viome";

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

  # Config files
  home.file = {
    # ".npmrc" = {
    #   text = ''
    #     prefix=/home/berti/.npm-global
    #   '';
    # };
  };

  # Packages
  home.packages = [
    # system
    pkgs.nixpkgs-fmt
    pkgs.ksshaskpass

    # Fonts
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk
    pkgs.noto-fonts-emoji

    # utils
    pkgs.git
    pkgs.btop
    pkgs.fastfetch
    pkgs.bat

    # browsers
    pkgs.google-chrome

    # media
    pkgs.vlc
    pkgs.obs-studio
    pkgs.shotcut
    pkgs.ffmpeg-full
    pkgs.guvcview

    # comms
    pkgs.slack
    pkgs.zoom-us

    # dev
    pkgs.vscode
    pkgs.distrobox
    pkgs.podman-compose
    pkgs.jetbrains.idea-community-bin
    pkgs.beekeeper-studio
    pkgs.lens
    pkgs.nodejs_20
    (pkgs.sbt-extras.override { jdk = pkgs.temurin-bin-8; })
    pkgs.awscli2
    pkgs.maven
  ];

}
