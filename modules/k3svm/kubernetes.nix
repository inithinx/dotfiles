{
  config,
  lib,
  pkgs,
  microvm,
  ...
}:
{

  # Enable SSH for remote access.
  services.openssh.enable = true;

  # Install nessary packages.
  environment.systemPackages = with pkgs; [
    kubectl
    helm
    iptables
    ethtool
    nfs-utils
    neovim
    htop-vim
  ];

  # ISCSI and Nixos Preperation for longhorn.
  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
  };
  systemd.tmpfiles.rules = [ "L+ /usr/local/bin - - - - /run/current-system/sw/bin/" ];

  # Needed modules and sysctl confs for kubernetes.
  boot.kernelModules = [
    "br_netfilter"
    "rbd"
    "overlay"
  ];

  # Firewall config for kubernetes.
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [
      22
      80
      443
      6443
    ];
    allowedUDPPorts = [ 443 ];
  };

  # Kubernetes setup
  services.k3s = {
    enable = true;
    clusterInit = false;
    token = "test";
    # Conditional server address
    serverAddr = if config.networking.hostName != "alpha" then "https://10.0.0.11:6443" else "";
    # Conditional role assignment
    role = if config.networking.hostName == "alpha" then "server" else "agent";
    disableAgent = (config.networking.hostName == "alpha");
    extraFlags = toString (
      [ "--write-kubeconfig-mode \"0644\"" ]
      ++ (
        if config.networking.hostName == "alpha" then
          [
            "--disable servicelb"
            "--disable traefik"
            "--disable local-storage"
          ]
        else
          [ ]
      )
    );
  };
}
