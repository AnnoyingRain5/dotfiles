{ config, pkgs, inputs, ... }:

{
	imports = [../../configuration.nix ./hardware-configuration.nix];
	networking.hostName = "Jolteon";
}
