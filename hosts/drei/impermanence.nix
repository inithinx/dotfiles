{config, pkgs, lib, inputs, home-manager, ... }: {

  # Needed for Booting NixOs.
  # NixOs Setup
  environment.persistence."/persist" ={
    enable = true;
    hideMounts = true;
    directories = [
      { directory = "/etc/nixos"; user = "nithin"; group = "users"; mode= "u=rwx,g=rx,o="; }
      "/etc/secureboot"
      "/etc/NetworkManager/system-connections"
      "/var/log"
      "/var/lib/acme"
      "/var/lib/nixos" # without this, users and groups get fucked or something ?
      #"/var/lib/bitwarden_rs"
      #"/var/lib/docker"
      #"/var/lib/redis-nextcloud"
      #"/var/lib/samba"
      {directory="/var/lib/private"; mode="u=rwx,g=,o="; }
      {directory="/var/lib/deluge"; user="nithin"; group="users";}
      {directory="/var/lib/jellyfin"; user="nithin"; group="users";}
      "/var/lib/sonarr"
      "/var/lib/radarr"
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
      ];
    };
  };
  programs.fuse.userAllowOther = true;

}
