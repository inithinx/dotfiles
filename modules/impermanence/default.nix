{
  inputs,
  config,
  lib,
  ...
}:
with lib; let
  # Helper function to create media directories with consistent permissions
  mkMediaDir = path: {
    directory = path;
    user = config.mediastack.user or config.base.username;
    group = config.mediastack.group or "users";
  };
in
  # Check if proxy should be enabled (mirrors logic from proxy module)
  #proxyEnabled = config.proxy.enable or (
  #  config.mediastack.enable or false ||
  #  config.selfhosted.enable or false
  #);
  {
    imports = [
      inputs.impermanence.nixosModules.impermanence
      inputs.disko.nixosModules.default
    ];

    options.impermanence = {
      enable = mkOption {
        type = types.bool;
        default = config.base.enable;
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
        mount ${config.disko.devices.disk.main.device}/root /btrfs_tmp
        rm -rf /btrfs_tmp/*
        btrfs subvolume create /${config.disko.devices.disk.main.device}/root
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
              directory = "/var/lib/sbctl";
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
          #++ (optionals config.proxy.enable [
          #  "/var/lib/acme"
          #])
          # Add media stack directories if enabled
          #++ (optionals (config.mediastack.enable or false) [
          #  "/var/lib/docker"
          #  {
          #    directory = "/var/lib/private";
          #    mode = "u=rwx,g=,o=";
          #  }
          #  (mkMediaDir "/var/lib/deluge")
          #  (mkMediaDir "/var/lib/jellyfin")
          #  (mkMediaDir "/var/lib/sonarr")
          #  (mkMediaDir "/var/lib/radarr")
          #  (mkMediaDir "/var/lib/lidarr")
          #])
          ++ config.impermanence.extraDirs;

        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];

        users.${config.base.username} = {
          home = "/home/${config.base.username}";
          directories = [
            ".ssh"
            "." # As you noted in the comment, this is temporary
          ];
        };
      };

      # Ensure Fuse works for mounted directories
      programs.fuse.userAllowOther = true;
    };
  }
