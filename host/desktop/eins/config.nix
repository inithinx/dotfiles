{ ... }:
{

  boot = {
    kernelModules = [ "kvm-amd" ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    teams
    whatsapp-for-linux
    steam
    spotify-qt
  ];

}
