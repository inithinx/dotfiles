{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.microvm.nixosModules.host
  ];

  options.k3svm = with lib; {
    enable = mkEnableOption "k3s microvm cluster";

    numberOfVMs = mkOption {
      type = types.int;
      default = 3;
      description = "Number of VMs to create for the k3s cluster";
    };

    cpusPerVM = mkOption {
      type = types.int;
      default = 4;
      description = "Number of CPUs per VM";
    };

    memoryPerVM = mkOption {
      type = types.int;
      default = 4096;
      description = "Memory in MB per VM";
    };

    storagePerVM = mkOption {
      type = types.int;
      default = 25600;
      description = "Storage size in MB per VM";
    };

    bridgehosts = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of host network interfaces to bridge to the VMs";
    };
  };

  config = lib.mkIf config.k3svm.enable {
    microvm.vms = lib.genAttrs (map (n: "prod-${toString n}") (lib.range 1 config.k3svm.numberOfVMs)) (
      name: let
        vmNumber = lib.toInt (lib.last (lib.splitString "-" name));
      in {
        config = {
          microvm = {
            hypervisor = "qemu";
            vcpu = config.k3svm.cpusPerVM;
            mem = config.k3svm.memoryPerVM;
            volumes = [
              {
                image = "/media/microvms/${name}.img";
                size = config.k3svm.storagePerVM;
                autoCreate = true;
                fsType = "ext4";
                mountPoint = "/";
              }
            ];
            shares = [
              {
                tag = "nixstore";
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
                proto = "virtiofs";
              }
            ];
            writableStoreOverlay = "/nix/.rw-store";
            interfaces = [
              {
                id = name; # Use the VM name as the interface ID
                type = "bridge";
                bridge = "br0";
                mac = "52:54:00:${builtins.substring 0 2 (builtins.hashString "sha256" name)}:${
                  builtins.substring 2 2 (builtins.hashString "sha256" name)
                }:${builtins.substring 4 2 (builtins.hashString "sha256" name)}";
              }
            ];
          };

          users.users.${name} = {
            isNormalUser = true;
            initialPassword = "${name}"; # Note: This is insecure for production!
            description = "Test user for microVMs";
            extraGroups = ["wheel"]; # Optional: Grants sudo privileges.
          };
          services.k3s = {
            enable = true;
            role = "server";
            tokenFile = "/var/lib/rancher/k3s/server/token";
            extraFlags = toString (
              [
                "--write-kubeconfig-mode \"0644\""
                "--disable local-storage"
              ]
              ++ (
                if vmNumber == 1
                then ["--cluster-init"]
                else ["--server https://10.0.0.51:6443"]
              )
            );
            clusterInit = vmNumber == 1;
          };

          services.tailscale.enable = true;
          services.openiscsi = {
            enable = true;
            name = "iqn.2016-04.com.open-iscsi:${name}";
          };

          environment.systemPackages = with pkgs; [
            neovim
            k3s
            cifs-utils
            nfs-utils
            git
            htop
            iptables
            curl
            wget
          ];

          boot.kernelParams = [
            "console=ttyS0"
            "panic=1"
            "boot.panic_on_fail"
            "net.ifnames=0"
          ];

          services.openssh.enable = true;

          system.stateVersion = "24.11";
          networking = {
            interfaces.eth0 = {
              useDHCP = true; # Enable DHCP just for eth0
            };
            defaultGateway = {
              address = "10.0.0.1";
              interface = "eth0";
            };
            firewall = {
              enable = true;
              allowedTCPPorts = [
                22 # SSH
                6443 # Kubernetes API
                10250 # Kubelet
                2379 # etcd client
                2380 # etcd peer
                80 # Http
                443 # Https
              ];
            };
          };
        };
      }
    );

    # Host system configuration
    systemd.services.prepare-microvm-storage = {
      description = "Prepare storage directory for MicroVMs";
      wantedBy = ["multi-user.target"];
      script = ''
        mkdir -p /media/microvms
        chown microvm:microvm /media/microvms
        chmod 755 /media/microvms
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    networking.bridges."br0".interfaces = config.k3svm.bridgehosts;

    users.users.microvm = {
      isSystemUser = true;
      description = "MicroVM user";
    };

    users.groups.microvm = {};
  };
}
