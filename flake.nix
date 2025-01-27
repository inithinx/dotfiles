{
  description = "Nithin's NixOS Flake";
  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {nixpkgs, ...}: let
    systems = [
      "x86_64-linux"
      #"aarch64-linux" #Might add rpi4 later.
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    nixosSystem = hostname:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./profiles/${hostname}];
      };
  in {
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules;
    nixosConfigurations = {
      citadel = nixosSystem "citadel";
      pathfinder = nixosSystem "pathfinder";
      singularity = nixosSystem "singularity";
    };
  };
}
