{ config, lib, pkgs, modulesPath, inputs, ... }: {

  boot = {
    consoleLogLevel = 0;
    kernelModules = [ "kvm-amd"  ];
    kernelParams = [ "quiet" ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci"  "usb_storage" "sd_mod" ];
      systemd.enable = true;
      verbose = false;
    };
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      systemd-boot.consoleMode = "max";
      efi.canTouchEfiVariables = true;
    };
  };

  environment.systemPackages = [ inputs.agenix.packages."x86_64-linux".default ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = [ pkgs.libva ];
  };

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.hostName = "drei";
  networking.firewall.allowedTCPPorts = [ 22 443 80 53 25565 5349 5350 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedUDPPortRanges = [ {from=49512; to=49999;}];
  networking.firewall.enable = true;
  services.fstrim.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
