{
  description = "System flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-vkl.url = "github:Scrumplex/nixpkgs/nixos/monado/vulkan-layers";
    nur.url = "github:nix-community/NUR";
    #nur.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    flake-firefox-nightly.url = "github:nix-community/flake-firefox-nightly";

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";

    stardust.url = "github:StardustXR/server";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
  };

  outputs = { self, nixpkgs, home-manager, nur, nix-vscode-extensions, nixpkgs-xr, flatpaks, nixpkgs-vkl, stardust, flake-firefox-nightly }@inputs: {
    nixosConfigurations = {

      Blaze = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;

          nixpkgs-vkl = import nixpkgs-vkl {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/Blaze/configuration.nix
          nur.nixosModules.nur
          flatpaks.nixosModules.default
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
          nixpkgs-vkl = import nixpkgs-vkl {
            inherit system;
            config.allowUnfree = true;
          };
          stardust = import stardust {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/Dragon/configuration.nix
          nur.nixosModules.nur
          flatpaks.nixosModules.default
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
