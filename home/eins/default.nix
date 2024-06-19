{pkgs, lib, config, ...}:{

# Home-Manager Setup
  #programs.fuse.userAllowOther = true; # needed for home manager to persist stuff.
  #imports = [ impermanence.nixosModules.home-manager.impermanence ];
  home = {
    username = "nithin";
    homeDirectory = "/home/nithin";
    stateVersion = "24.05";
    #persistence."/persist/home" = {
    #  directories = [
    #    "Downloads"
    #    "Music"
    #    "Pictures"
    #    "Documents"
    #    "Videos"
    #    { directory = ".ssh"; mode = "0700"; }
    #  ];
    #  files = [
    #    ".bashrc"
    #  ];
    #};
  };
}
