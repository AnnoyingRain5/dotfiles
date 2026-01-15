{
  description = "System flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-25-11.url = "nixpkgs/nixos-25.11";
    nur.url = "github:nix-community/NUR";
    #nur.inputs.nixpkgs.follows = "nixpkgs";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    flake-firefox-nightly.url = "github:nix-community/flake-firefox-nightly";

    flatpaks.url = "github:GermanBread/declarative-flatpak/latest";

    qemu-applesilicon.url = "github:onny/nixpkgs/qemu-applesilicon";

    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
    minecraft-plymouth.url = "github:AnnoyingRain5/minecraft-plymouth-theme/fix-nix";

    stardust.url = "github:StardustXR/server";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";

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
      nixpkgs-25-11,
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
            nixpkgs-25-11 = import nixpkgs-25-11 {
              inherit system;
            };
          };
          modules = [
            ./hosts/Dragon/configuration.nix
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
      };
    };
}
