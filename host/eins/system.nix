{ inputs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    consoleLogLevel = 0;
    kernelModules = [ "kvm-amd"  ];
    kernelParams = [ "quiet" "splash" ];
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
    plymouth ={
      enable = true;
      #theme = lib.mkForce "bgrt";
      theme = "bgrt";
    }
  };

  networking = {
    #useDHCP = lib.mkDefault true;
    hostName = "eins";
    firewall.allowedTCPPorts = [ 22 ];
    firewall.allowedUDPPorts = [ ];
    firewall.enable = true;
    networkmanager.enable = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 10;
  };

  services.fstrim.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
