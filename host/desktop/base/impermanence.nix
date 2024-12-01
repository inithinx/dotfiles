{
  config,
  pkgs,
  lib,
  inputs,
  home-manager,
  ...
}:
{

  # Needed for Booting NixOs.
  # NixOs Setup
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      {
        directory = "/etc/nixos";
        user = "nithin";
        group = "users";
        mode = "u=rwx,g=rx,o=";
      }
      "/etc/secureboot"
      #"/etc/ssh"
      "/etc/NetworkManager/system-connections"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      #"/etc/ssh/ssh_known_hosts"
    ];
    users.nithin.home = "/home/nithin";
    users.nithin = {
      directories = [
        ".ssh"
        "Desktop"
        "Documents"
        "Downloads"
        ".config"
      ];
      files = [ ".zshrc" ];
    };
  };
  programs.fuse.userAllowOther = true;

}
