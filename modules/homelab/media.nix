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
    # openFirewall = true; # Uncomment if needed
    user = "nithin";
    group = "users";
    # dataDir = "/data/jellyfin"; # Uncomment if needed
    # configDir = "/data/jellyfin/config"; # Uncomment if needed
    # cacheDir = "/data/jellyfin/cache"; # Uncomment if needed
  };

  users.users.jellyfin = {
    extraGroups = [
      "render"
      "video"
    ];
    isSystemUser = true;
    group = "users";
  };

  services.sonarr = {
    enable = true;
    user = "nithin";
    group = "users";
  };

  nixpkgs.config.permittedInsecurePackages = [ # Use with caution!
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];

  services.radarr = {
    enable = true;
    # user = "nithin"; # Uncomment if needed
    # group = "users"; # Uncomment if needed
  };

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
  };

  # services.flaresolverr = { # Use Nix package if desired
  #   enable = true;
  #   port = 8191;
  #   package = pkgs.flaresolverr;
  # };

  virtualisation.oci-containers = {
    backend = "docker";
    containers.flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      autoStart = true;
      ports = [ "127.0.0.1:8191:8191" ];
      environment = {
        LOG_LEVEL = "warning";
        LOG_HTML = "false";
        CAPTCHA_SOLVER = "hcaptcha-solver"; # Ensure this is configured correctly
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
      # "/var/lib/redis-nextcloud" # Uncomment if needed
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
