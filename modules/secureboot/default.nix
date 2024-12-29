{
  inputs,
  lib,
  ...
}:
with lib; {
  options.secureboot = {
    enable = mkOption {
      type = types.bool;
      default = config.base.enable;
      description = "Enable secure boot configuration using lanzaboote.";
    };
  };
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  config = mkIf config.secureboot.enable {
    environment.systemPackages = [pkgs.sbctl];
    boot.loader.systemd-boot.enable = mkForce false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
}
