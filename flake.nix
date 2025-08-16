{
  description = "System flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    #nur.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    flake-firefox-nightly.url = "github:nix-community/flake-firefox-nightly";

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";

    stardust.url = "github:StardustXR/server";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr/45662f1617fc07a19528fbf5d268488664cd8d72"; # I have no clue why, but on latest git (16/8/2025), anything that connects to Monado segfaults
                                                                                                 # this will have to do for now

    nvidia-patch.url = "github:icewind1991/nvidia-patch-nixos";
    nvidia-patch.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nur,
      nix-vscode-extensions,
      nixpkgs-xr,
      flatpaks,
      stardust,
      flake-firefox-nightly,
      nvidia-patch
    }@inputs:
    {
      nixosConfigurations = {

        Blaze = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/Blaze/configuration.nix
            nur.modules.nixos.default
            flatpaks.nixosModule
            nixpkgs-xr.nixosModules.nixpkgs-xr
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };

        Dragon = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            stardust = import stardust {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./hosts/Dragon/configuration.nix
            nur.modules.nixos.default
            flatpaks.nixosModule
            nixpkgs-xr.nixosModules.nixpkgs-xr
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
      };
    };
}
