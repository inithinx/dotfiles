{
  config,
  lib,
  pkgs,
  modulesPath,
  meta,
  ...
}:
{
  imports = [
    ./disko.nix
    ./config.nix
  ];
}
