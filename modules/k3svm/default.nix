{
  config,
  lib,
  pkgs,
  microvm,
  ...
}:
{

  # Set up autostart for vms.
  microvm.autostart = [
    "alpha"
    "delta"
    "gamma"
  ];
  microvm.stateDir = "/data/microvms";

  # Set up vms for kubernetes
  microvm.vms = {
    # Node 1
    alpha = {
      config =
        { pkgs, ... }:
        {
          microvm = {
            hypervisor = "qemu";
            vcpu = 4;
            mem = 5000;
            volumes = [
              {
                mountPoint = "/";
                size = 66560; # 50GB
                image = "/data/microvms/alpha/alpha.img";
              }
            ];
            interfaces = [
              {
                type = "bridge";
                bridge = "br0";
                id = "alpha";
                mac = "02:00:00:00:00:01";
              }
            ];
            shares = [
              {
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
                tag = "ro-store";
                proto = "virtiofs";
              }
            ];
          };

          users.users.alpha = {
            isNormalUser = true;
            extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
            initialPassword = "alpha";
          };
          networking.hostName = "alpha";
          imports = [ ./kubernetes.nix ];

        };
    };

    # Node 2
    delta = {
      config =
        { pkgs, ... }:
        {
          microvm = {
            hypervisor = "qemu";
            vcpu = 4;
            mem = 5000;
            volumes = [
              {
                mountPoint = "/";
                size = 66560; # 50GB
                image = "/data/microvms/delta/delta.img";
              }
            ];
            interfaces = [
              {
                type = "bridge";
                bridge = "br0";
                id = "worker2";
                mac = "02:00:00:00:00:02";
              }
            ];
            shares = [
              {
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
                tag = "ro-store";
                proto = "virtiofs";
              }
            ];
          };

          users.users.delta = {
            isNormalUser = true;
            extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
            initialPassword = "delta";
          };

          networking.hostName = "delta";
          imports = [ ./kubernetes.nix ];

        };
    };

    # Node 3
    gamma = {
      config =
        { pkgs, ... }:
        {
          microvm = {
            hypervisor = "qemu";
            vcpu = 4;
            mem = 5000;
            volumes = [
              {
                mountPoint = "/";
                size = 66560; # 50GB
                image = "/data/microvms/gamma/gamma.img";
              }
            ];
            interfaces = [
              {
                type = "bridge";
                bridge = "br0";
                id = "gamma";
                mac = "02:00:00:00:00:03";
              }
            ];
            shares = [
              {
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
                tag = "ro-store";
                proto = "virtiofs";
              }
            ];
          };
          users.users.gamma = {
            isNormalUser = true;
            extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
            initialPassword = "gamma";
          };

          networking.hostName = "gamma";
          imports = [ ./kubernetes.nix ];

        };
    };

  };
}
