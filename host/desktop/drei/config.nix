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

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "nithin";

}
