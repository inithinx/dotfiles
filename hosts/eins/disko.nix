{

  disko.devices = {
    disk.main = {
      # FIXME add device here before running.
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
          nix = {
            size = "100%";
	    name = "nix";
	    content = {
	      type = "btrfs";
	      extraArgs = [ "-f" ];
	      subvolumes = {
	        "/nix" = {
	           mountpoint = "/nix";
		   mountOptions = [ "noatime" "nodiratime" "compress=zstd" "ssd" ];
	        };
	        "/persist" = {
	          mountpoint = "/persist";
		  mountOptions = [ "noatime" "nodiratime" "compress=zstd" "ssd" ];
	        };
	        };
	      };
	    };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=1G"
        "defaults"
        "mode=755"
      ];
    };
  };

}
