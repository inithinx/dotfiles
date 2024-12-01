{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{

  services.jellyfin = {
    enable = true;
    #openFirewall = true;
    user = "nithin";
    group = "users";
    #dataDir = "/data/jellyfin";
    #configDir = "/data/jellyfin/config";
    #cacheDir = "/data/jellyfin/cache";
  };

  users.users.jellyfin = {
    extraGroups = [
      "render"
      "video"
    ]; # Access to /dev/dri
    isSystemUser = true;
    group = "users";
  };

  #services.sonarr = {
  #  enable = true;
  #  user = "nithin";
  #  group = "users";
  #dataDir = "/data/sonarr";
  #};
  #nixpkgs.config.permittedInsecurePackages = [
  #  "aspnetcore-runtime-wrapped-6.0.36"
  #];

  #services.radarr = {
  #  enable = true;
  #  user = "nithin";
  #  group = "users";
  #dataDir = "/data/radarr";
  #};

  services.prowlarr = {
    enable = true;
  };

  services.jellyseerr = {
    enable = true;
  };

  services.deluge = {
    enable = true;
    user = "nithin";
    group = "users";
    web.enable = true;
    #dataDir = "/data/deluge";
  };

  #services.flaresolverr = {
  #  enable = true;
  #  port = 8191;
  #  package = pkgs.flaresolverr;
  #};

  # Flaresolverr broken for now, using docker as fallback.

  virtualisation.oci-containers = {
    backend = "docker";
    containers.flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      autoStart = true;
      ports = [ "127.0.0.1:8191:8191" ];
      environment = {
        LOG_LEVEL = "warning";
        LOG_HTML = "false";
        CAPTCHA_SOLVER = "hcaptcha-solver";
        TZ = "Asia/Kolkata";
      };
    };
  };

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib/acme"
      "/var/lib/docker"
      #"/var/lib/redis-nextcloud"
      {
        directory = "/var/lib/private";
        mode = "u=rwx,g=,o=";
      }
      {
        directory = "/var/lib/deluge";
        user = "nithin";
        group = "users";
      }
      {
        directory = "/var/lib/jellyfin";
        user = "nithin";
        group = "users";
      }
      "/var/lib/sonarr"
      "/var/lib/radarr"
    ];
  };

}
