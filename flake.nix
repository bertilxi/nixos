{
  description = "NixOS configuration";

  inputs = {
    hosts.url = github:StevenBlack/hosts;
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, hosts, nixos-hardware, ... }: {
    nixosConfigurations.one = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-cpu-amd-raphael-igpu
        nixos-hardware.nixosModules.common-gpu-amd
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-acpi_call
        nixos-hardware.nixosModules.common-pc-laptop-ssd

        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.berti = import ./home-personal.nix;
          home-manager.users.berti-viome = import ./home-work.nix;
        }

        hosts.nixosModule
        {
          networking.stevenBlackHosts = {
            enable = true;
            blockFakenews = true;
            blockGambling = true;
            blockPorn = true;
            blockSocial = false;
          };
        }

      ];
    };
  };
}
