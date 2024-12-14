{
  description = "Nithin's NixOS Flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      lanzaboote,
      nixvim,
      disko,
      agenix,
      impermanence,
      microvm,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      nodes = [
        "citadel"
        "pathfinder"
        "singularity"
      ];
    in
    {
      nixosConfigurations = builtins.listToAttrs (
        map (name: {
          name = name;
          value = nixpkgs.lib.nixosSystem {
            specialArgs = {
              meta = {
                hostname = name;
              };
              inherit inputs;
            };
            system = "x86_64-linux";
            modules =
              let
                desktopModules = [
                  ./host/desktop
                  (if name == "citadel" then ./host/desktop/citadel else null)
                  (if name == "pathfinder" then ./host/desktop/pathfinder else null)
                ];
                serverModules = [
                  ./host/server
                  agenix.nixosModules.default
                  ./modules/agenix
                  #microvm.nixosModules.host
                  # Optional modules
                  # ./modules/k3svm
                  ./modules/homelab
                ];
              in
              lib.filter (mod: mod != null) (
                [
                  lanzaboote.nixosModules.lanzaboote
                  ./modules/lanzaboote
                  nixvim.nixosModules.nixvim
                  ./modules/nixvim
                  disko.nixosModules.default
                  impermanence.nixosModules.impermanence
                  # NOTE:- impermanence config files are imported on a hostname basis, see in the appropriate hostname-level configs.
                ]
                ++ (if name == "citadel" || name == "pathfinder" then desktopModules else serverModules)
              );
          };
        }) nodes
      );
    };
}
