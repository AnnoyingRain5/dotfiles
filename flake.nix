{
	description = "System flake";
	inputs =  {
		nixpkgs.url = "nixpkgs/nixos-23.11";
	};
	
	outputs = {self, nixpkgs }: { 
		nixosConfigurations = {
			Flareon = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [./hosts/Flareon/configuration.nix];
			};
			Jolteon = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [./hosts/Jolteon/configuration.nix];
			};
		};
	};
}
