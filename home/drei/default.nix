{pkgs, lib, config, inputs, impermanence, ...}:{

# Home-Manager Setup
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
