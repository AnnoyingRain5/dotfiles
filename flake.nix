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
