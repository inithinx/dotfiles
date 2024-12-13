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
    ./system.nix
    ./impermanence.nix
  ];
}
