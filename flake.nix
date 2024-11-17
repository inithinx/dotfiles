{
description = "Nithin's NixOs Flake";

##############
### INPUTS ###
##############
inputs = {
  nixpkgs = { 
    url = "github:nixos/nixpkgs/nixos-unstable"; 
  };
  lanzaboote ={
    url = "github:nix-community/lanzaboote";
  };
  nixvim = {
    url = "github:nix-community/nixvim";
  };
  disko = {
    url = "github:nix-community/disko";
  };
  impermanence = {
    url = "github:nix-community/impermanence";
  };
  agenix = {
    url = "github:ryantm/agenix";
  };
  microvm = {
    url = "github:astro/microvm.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

###############
### OUTPUTS ###
###############
  outputs = { self, nixpkgs, lanzaboote, nixvim, disko, agenix, impermanence, microvm,  ...}@inputs: {
    # Server Profile
    nixosConfigurations = {
      drei = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Import Server-Specific files.
          ./host/drei
          # Import Lanzaboote provided module and custom config.
          lanzaboote.nixosModules.lanzaboote
          ./modules/lanzaboote
          # Import NixVim provided module and custom config.
          nixvim.nixosModules.nixvim
          ./modules/nixvim
	        # Disko
	        disko.nixosModules.default
	        # Impermanence
	        impermanence.nixosModules.impermanence
          # Optionally import vm setup with k3s HA Cluster
          # WARNING!!! Needs further network setup.
          #microvm.nixosModules.host
          #./modules/k3svm
          # Optionally import homelab setup
          ./modules/homelab
        ];
      };
    };
  };
}
