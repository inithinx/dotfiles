{ pkgs, ... }:
{

  boot = {
    kernelModules = [ "kvm-intel" ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
      ];
    };
  };

  # KDE
  services.displayManager.sddm.enable = true;
  services.xserver.enable = false;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

}
