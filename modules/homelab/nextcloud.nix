{ config, lib, pkgs, modulesPath, ... }: {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "cloud.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
    #hostName = "cloud.nanosec.dev";
    home = "/data/nextcloud";
    config.adminpassFile = config.age.secrets.nc.path;
    config.dbtype = "pgsql";
    config.dbuser = "nextcloud";
    config.dbname = "nextcloud";
    config.adminuser = "nithin";
    configureRedis = true;
    maxUploadSize = "1G";
    https = true;
    database.createLocally = true;
    poolSettings = {
      "pm" = "ondemand";
      "pm.max_children" = 32;
      "pm.process_idle_timeout" = "10s";
      "pm.max_requests" = 500;
    };
    appstoreEnable = true;
    autoUpdateApps.enable = true;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) contacts calendar deck previewgenerator spreed;
    };
  phpOptions."opcache.interned_strings_buffer" = "23";
  extraAppsEnable = true;
    settings = {
      enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
    	  "OC\\Preview\\Krita"
    	  "OC\\Preview\\MarkDown"
    	  "OC\\Preview\\MP3"
    	  "OC\\Preview\\OpenDocument"
    	  "OC\\Preview\\PNG"
    	  "OC\\Preview\\TXT"
    	  "OC\\Preview\\XBitmap"
    	  "OC\\Preview\\HEIC"
    	];
      #maintenance_window_start = 1;
      default_phone_region = "IN";
      logLevel=0;
    };
  };


  virtualisation.oci-containers = {
    backend = "docker";
    containers.collabora = {
      image = "collabora/code";
      autoStart = true;
      ports = ["127.0.0.1:9980:9980"];
      environment = {
        domain = "office-cloud.nanosec.dev";
        extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
      };
      extraOptions = ["--cap-add" "MKNOD"];
    };
  };
}
