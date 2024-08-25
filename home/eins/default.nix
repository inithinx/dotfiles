{pkgs, lib, config, ...}:{

# Home-Manager Setup
  programs.fuse.userAllowOther = true; # needed for home manager to persist stuff.
  home = {
    username = "nithin";
    homeDirectory = "/home/nithin";
    stateVersion = "24.05";
  };
}
