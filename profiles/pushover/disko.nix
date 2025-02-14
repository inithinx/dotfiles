{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/nvme-CT500P1SSD8_2033E4A98CDD";
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
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
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
              };
            };
          };
        };
      };
    };
  };
}
