{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  #### 1️⃣ Import Required Modules ####
  imports = [
    inputs.microvm.nixosModules.host  # Import MicroVM module
  ];

  #### 2️⃣ Define Available Options ####
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

    tapHost = mkOption {
      type = types.str;
      default = "";
      description = "List of host network interfaces to bridge to the VMs";
    };

    tailscale = {
      enable = mkEnableOption "Enable automatic Tailscale authentication";

      domain = mkOption {
        type = types.str;
        description = "Tailscale base domain (e.g., ruffe-tetra.ts.net). This is mandatory.";
        example = "ruffe-tetra.ts.net";
      };

      authkey = mkOption {
        type = types.str;
        default = "";
        description = "Tailscale authentication key";
        example = "tskey-abc123...";
      };
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Custom base domain for the Kubernetes API. If set, 'api.' is automatically prepended.";
      example = "nanosec.dev";
    };
  };

  #### 3️⃣ Apply Configuration Based on Options ####
  config = lib.mkIf config.k3svm.enable {
    # Ensure `tailscale.domain` is mandatory
    assertions = [
      {
        assertion = config.k3svm.tailscale.domain != null;
        message = "Error: `k3svm.tailscale.domain` is required. Please provide the Tailscale base domain (e.g., ruffe-tetra.ts.net).";
      }
    ];

    microvm.vms = lib.genAttrs (map (n: "prod-${toString n}") (lib.range 1 config.k3svm.numberOfVMs)) (
      name: let
        vmNumber = lib.toInt (lib.last (lib.splitString "-" name));
        baseDomain =
          if config.k3svm.domain != null
          then "api.${config.k3svm.domain}" # Custom domain → api.nanosec.dev
          else "prod-${toString vmNumber}.${config.k3svm.tailscale.domain}"; # Tailscale → prod-1.ruffe-tetra.ts.net
      in {
        config = {
          microvm = {
            hypervisor = "cloud-hypervisor";
            vcpu = config.k3svm.cpusPerVM;
            mem = config.k3svm.memoryPerVM;
            volumes = [
              {
                image = "/media/microvms/${name}-store.img";
                size = config.k3svm.storagePerVM;
                autoCreate = true;
                fsType = "ext4";
                mountPoint = "/var/lib/longhorn";
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

	    # Networking
            interfaces = [
              {
                id = name;
                type = "macvtap";
                macvtap.link = config.k3svm.tapHost;
		macvtap.mode = "bridge";
                mac = "52:54:00:${builtins.substring 0 2 (builtins.hashString "sha256" name)}:${
                  builtins.substring 2 2 (builtins.hashString "sha256" name)
                }:${builtins.substring 4 2 (builtins.hashString "sha256" name)}";
              }
            ];
          };

          users.users.${name} = {
            isNormalUser = true;
            initialPassword = "${name}";
            description = "Test user for microVMs";
            extraGroups = ["wheel"];
          };

          # Enable k3s
          services.k3s = {
            enable = true;
            role = "server";
            token = "temp";
            extraFlags =
              [
                "--write-kubeconfig-mode=0644"
                "--disable=local-storage"
                "--vpn-auth=name=tailscale,joinKey=${config.k3svm.tailscale.authkey}"
              ]
              ++ (
                if vmNumber == 1
                then ["--cluster-init"]
                else ["--server=https://${baseDomain}:6443"]
              );
          };

          # Fix the PATH issue in k3s systemd service using mkForce
          systemd.services.k3s.environment.PATH = lib.mkForce "/run/current-system/sw/bin:/usr/bin:/bin";

          # Enable Tailscale
          services.tailscale.enable = true;

          # Fixes for Longhorn and systemd path issues
          systemd.tmpfiles.rules = [
            "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
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
            interfaces.eth0.useDHCP = true;
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
                41641 # Tailscale
              ];
              allowedUDPPorts = [
                41641 # Tailscale
                8472  # Flannel VXLAN
              ];
            };
          };
        };
      }
    );

    users.users.microvm = {
      isSystemUser = true;
      description = "MicroVM user";
    };

    users.groups.microvm = {};
  };
}
