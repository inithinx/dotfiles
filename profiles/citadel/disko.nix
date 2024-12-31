{
  disko.devices = {
    disk.main = {
      device = "";
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
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "eins";
              settings.allowDiscards = true;
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
                };
              };
            };
          };
        };
      };
    };
  };
}
