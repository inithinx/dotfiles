{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.mediastack;
in {
  options.mediastack = {
    enable = mkEnableOption "Media server stack";

    user = mkOption {
      type = types.str;
      default = "${config.base.username}";
      description = "User under which media services will run";
    };

    group = mkOption {
      type = types.str;
      default = "users";
      description = "Group under which media services will run";
    };
  };

  config = mkIf cfg.enable {
    # Enable required insecure packages for Radarr/Sonarr
    nixpkgs.config.permittedInsecurePackages = [
      "aspnetcore-runtime-6.0.36"
      "aspnetcore-runtime-wrapped-6.0.36"
      "dotnet-sdk-6.0.428"
      "dotnet-sdk-wrapped-6.0.428"
    ];

    # Jellyfin configuration
    services.jellyfin = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    users.users.jellyfin = {
      extraGroups = [
        "render"
        "video"
      ];
      isSystemUser = true;
      group = cfg.group;
    };

    # Sonarr configuration
    services.sonarr = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    # Lidarr configuration
    services.lidarr = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    # Radarr configuration
    services.radarr = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    # Prowlarr configuration
    services.prowlarr.enable = true;

    # Jellyseerr configuration
    services.jellyseerr.enable = true;

    # Deluge configuration
    services.deluge = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
      web.enable = true;
    };

    # FlareSolverr container configuration
    virtualisation.oci-containers = {
      backend = "docker";
      containers.flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        autoStart = true;
        ports = ["127.0.0.1:8191:8191"];
        environment = {
          LOG_LEVEL = "warning";
          LOG_HTML = "false";
          CAPTCHA_SOLVER = "hcaptcha-solver";
          TZ = "Asia/Kolkata";
        };
      };
    };
  };
}
