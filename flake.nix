{
  description = "System flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-old.url = "github:NixOS/nixpkgs/e8057b67ebf307f01bdcc8fba94d94f75039d1f6";
    nur.url = "github:nix-community/NUR";
    #nur.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";
  };

  outputs = { self, nixpkgs, home-manager, nur, nix-vscode-extensions, flatpaks, nixpkgs-old }@inputs: {
    nixosConfigurations = {

      Blaze = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;

          nixpkgs-old = import nixpkgs-old {
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
          nixpkgs-old = import nixpkgs-old {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/Dragon/configuration.nix
          nur.nixosModules.nur
          flatpaks.nixosModules.default
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
