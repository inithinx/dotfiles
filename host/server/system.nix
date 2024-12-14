{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  meta,
  ...
}:
{

  boot = {
    consoleLogLevel = 0;
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ "quiet" ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
      ];
      systemd.enable = true;
      verbose = false;
    };
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      systemd-boot.consoleMode = "max";
      systemd-boot.extraInstallCommands = ''
        if [ ! -d "/persist/etc/secureboot/keys" ]; then
          sbctl create-keys
        fi
      '';
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };
  };

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.hostName = meta.hostname;
  networking.firewall.allowedTCPPorts = [
    22
    443
    80
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];
  networking.firewall.enable = true;
  services.fstrim.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
