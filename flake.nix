{
  description = "System flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "nixpkgs/nixos-26.05";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    #nix-cachyos-kernel.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    flake-firefox-nightly.url = "github:nix-community/flake-firefox-nightly";
    flake-firefox-nightly.inputs.nixpkgs.follows = "nixpkgs";

    flatpaks.url = "github:GermanBread/declarative-flatpak/latest";

    qemu-applesilicon.url = "github:onny/nixpkgs/qemu-applesilicon";

    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
    minegrub-theme.inputs.nixpkgs.follows = "nixpkgs";

    minecraft-plymouth.url = "github:nikp123/minecraft-plymouth-theme";
    minecraft-plymouth.inputs.nixpkgs.follows = "nixpkgs";

    stardust.url = "github:StardustXR/server";
    stardust.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    nixpkgs-xr.inputs.nixpkgs.follows = "nixpkgs";

    rainspkgs.url = "github:AnnoyingRain5/rainspkgs";
    rainspkgs.inputs.nixpkgs.follows = "nixpkgs";

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
      qemu-applesilicon,
      minegrub-theme,
      minecraft-plymouth,
      nix-cachyos-kernel,
      nixpkgs-stable,
      rainspkgs,
    }@inputs:
    {
      nixosConfigurations = {

        Blaze = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/Blaze/configuration.nix
            nur.modules.nixos.default
            flatpaks.nixosModules.default
            nixpkgs-xr.nixosModules.nixpkgs-xr
            minegrub-theme.nixosModules.default
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
            nixpkgs-stable = import nixpkgs-stable {
              inherit system;
            };
          };
          modules = [
            ./hosts/Dragon/configuration.nix
            nur.modules.nixos.default
            flatpaks.nixosModules.default
            nixpkgs-xr.nixosModules.nixpkgs-xr
            minegrub-theme.nixosModules.default
            minecraft-plymouth.nixosModules.default
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
