{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/ata-CT240BX500SSD1_2335E872B8C6";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            size = "256M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          nix = {
            size = "100%";
            name = "nix";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "noatime"
                    "nodiratime"
                    "compress=zstd"
                    "ssd"
                  ];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [
                    "noatime"
                    "nodiratime"
                    "compress=zstd"
                    "ssd"
                  ];
                };
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "noatime"
                    "nodiratime"
                    "compress=zstd"
                    "ssd"
                  ];
                };
                "/data" = {
                  mountpoint = "/data";
                  mountOptions = [
                    "noatime"
                    "nodiratime"
                    "compress=zstd"
                    "ssd"
                  ];
                };
              };
            };
          };
        };
      };
    };
    disk.media = {
      device = "/dev/disk/by-id/ata-TOSHIBA_MQ04ABF100_69HCPJWAT";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          media = {
            size = "100%";
            name = "media";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/media";
              mountOptions = [
                "noatime"
                "nodiratime"
                "discard"
              ];
            };
          };
        };
      };
    };
  };
}
