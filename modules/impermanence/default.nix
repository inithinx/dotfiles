{
  config,
  lib,
  impermanence,
  ...
}:
with lib; let
  # Helper function to create media directories with consistent permissions
  mkMediaDir = path: {
    directory = path;
    user = config.mediastack.user or config.base.username;
    group = config.mediastack.group or "users";
  };
  # Check if proxy should be enabled (mirrors logic from proxy module)
  #proxyEnabled = config.proxy.enable or (
  #  config.mediastack.enable or false ||
  #  config.selfhosted.enable or false
  #);
in {
  imports = [
    impermanence.nixosModules.impermanence
  ];

  options.impermanence = {
    enable = mkOption {
      type = types.bool;
      default = mkDefault config.base.enable;
      description = "Enable the impermanence module.";
    };
    extraDirs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional directories to persist.";
    };
  };

  config = mkIf config.impermanence.enable {
    # Ensure persistence mount is ready at boot
    fileSystems."/persist".neededForBoot = true;

    # Wipe root on boot
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      mkdir /btrfs_tmp
      mount ${config.disko.devices.disk.main}/root /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi
      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }
      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done
      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';

    # Set up persistence
    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;
      directories =
        [
          {
            directory = "/etc/nixos";
            user = "${config.base.username}";
            group = "users";
            mode = "u=rwx,g=rx,o=";
          }
          {
            directory = "/etc/secureboot";
          }
          {
            directory = "/etc/NetworkManager/system-connections";
          }
          {
            directory = "/var/log";
          }
          {
            directory = "/var/lib/nixos";
          }
          {
            directory = "/var/lib/tailscale";
          }
        ]
        # Add proxy directories if proxy is enabled (directly or indirectly)
        ++ (optionals config.proxy.enable [
          "/var/lib/acme"
        ])
        # Add media stack directories if enabled
        ++ (optionals (config.mediastack.enable or false) [
          "/var/lib/docker"
          {
            directory = "/var/lib/private";
            mode = "u=rwx,g=,o=";
          }
          (mkMediaDir "/var/lib/deluge")
          (mkMediaDir "/var/lib/jellyfin")
          (mkMediaDir "/var/lib/sonarr")
          (mkMediaDir "/var/lib/radarr")
          (mkMediaDir "/var/lib/lidarr")
        ])
        ++ config.impermanence.extraDirs;

      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];

      users.${config.base.username}.home = "/home/${config.base.username}";
      users.${config.base.username} = {
        directories = [
          ".ssh"
          "." #TODO this just persists the entire home directory. this is not good, this is temp. make sure to use the home manager module to persist home stuff, then remove this.
        ];
      };
    };

    # Ensure Fuse works for mounted directories
    programs.fuse.userAllowOther = true;
  };
}
