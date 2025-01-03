{ inputs, ... }:
{

  modules = [
    inputs.microvm.nixosModules.host
  ];

  networking.interfaces.enp7s0.useDHCP = true;
  networking.interfaces.br0.useDHCP = true;
  networking.bridges = {
    "br0" = {
      interfaces = [ "enp7s0" ];
    };
  };

}
