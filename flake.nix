{
  description = "Nithin's NixOS Flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    lanzaboote = {
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
        "eins"
        "zwei"
        "drei"
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
                  (if name == "eins" then ./host/desktop/eins else null)
                  (if name == "zwei" then ./host/desktop/zwei else null)
                ];
                serverModules = [
                  ./host/server
                  agenix.nixosModules.default
                  ./modules/agenix
                  #microvm.nixosModules.host
                  # Optional modules
                  # ./modules/k3svm
                  # ./modules/homelab
                ];
              in
              lib.filter (mod: mod != null) (
                [
                  lanzaboote.nixosModules.lanzaboote
                  ./modules/lanzaboote
                  nixvim.nixosModules.nixvim
                  ./modules/nixvim
                  disko.nixosModules.defaultfl
                  impermanence.nixosModules.impermanence
                  # NOTE:- impermanence config files are imported on a hostname basis, see in the appropriate hostname-level configs.
                ]
                ++ (if name == "eins" || name == "zwei" then desktopModules else serverModules)
              );
          };
        }) nodes
      );
    };
}
