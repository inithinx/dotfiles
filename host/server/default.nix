{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    ./configuration.nix
    ./disko.nix
    ./system.nix
    ./impermanence.nix
  ];
}
