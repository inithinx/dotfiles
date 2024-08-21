{
description = "Nithin's NixOs Flake";

##############
### INPUTS ###
##############
inputs = {
  nixpkgs = { 
    url = "github:nixos/nixpkgs/nixos-unstable"; 
  };
  home-manager = {
    url = "github:nix-community/home-manager/";
  };
  lanzaboote ={
    url = "github:nix-community/lanzaboote";
  };
  nixvim = {
    url = "github:nix-community/nixvim";
  };
  agenix = {
    url = "github:ryantm/agenix";
  };
  disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  impermanence = {
    url = "github:nix-community/impermanence";
  };
};

###############
### OUTPUTS ###
###############
  outputs = { self, nixpkgs, home-manager, lanzaboote, agenix, nixvim, disko, impermanence, ...}@inputs: {
    # Desktop Profile
    nixosConfigurations = {
      eins = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Import Host-Specific files.
          ./hosts/eins
	        # Import Home-Manager provided modules and custom config.
	        home-manager.nixosModules.home-manager {
	          home-manager.useGlobalPkgs = true;
	          home-manager.useUserPackages = true;
	          home-manager.users.nithin = import ./home/eins;
          }
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
        ];
      };
    };
    # Server Profile
    nixosConfigurations = {
      drei = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Import Server-Specific files.
          ./hosts/drei
	        # Home Manager
	        home-manager.nixosModules.home-manager {
	          home-manager.useGlobalPkgs = true;
	          home-manager.useUserPackages = true;
	          home-manager.users.nithin = import ./home/drei;
          }
          # Import Lanzaboote provided module and custom config.
          lanzaboote.nixosModules.lanzaboote
          ./modules/lanzaboote
          # Import NixVim provided module and custom config.
          nixvim.nixosModules.nixvim
          ./modules/nixvim
          # Import AgeNix provided module and custom config.
          agenix.nixosModules.default
          ./modules/agenix
	        # Disko
	        disko.nixosModules.default
	        # Impermanence
	        impermanence.nixosModules.impermanence
        ];
      };
    };
  };

}
