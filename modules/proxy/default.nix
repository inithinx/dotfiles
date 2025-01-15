{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  #imports = [
  #  inputs.self.nixosModules.mediastack
  #  inputs.self.nixosModules.selfhosted
  #];
  options = {
    proxy = {
      enable = mkEnableOption "Enables nginx and ACME for fast, https reverse proxy.";
      default = true;
    };
  };
  config = mkIf config.proxy.enable {
    # Nginx
    services.nginx = {
      enable = true;
      package = pkgs.nginxQuic;

      # Recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = mkMerge [
        # Main domain redirect
        {
          "${config.age.secrets.domain.path}" = {
            forceSSL = true;
            useACMEHost = "primary-domain";
            locations."/" = {
              return = "301 https://${config.age.secrets.personaldomain.path}$request_uri";
            };
          };

          # Catch-all redirect for unused subdomains
          "~^(?<subdomain>.+)\.${config.age.secrets.domain.path}$" = {
            forceSSL = true;
            useACMEHost = "primary-domain";
            locations."/" = {
              return = "301 https://${config.age.secrets.personaldomain.path}$request_uri";
            };
            priority = 999; # Lower priority than specific service hosts
          };
        }

        # Mediastack services (conditionally included)
        (mkIf config.mediastack.enable {
          # Jellyfin
          "jellyfin.${config.age.secrets.domain.path}" = {
            forceSSL = true;
            useACMEHost = "primary-domain";
            locations."/" = {
              proxyPass = "http://127.0.0.1:8096";
              proxyWebsockets = true;
            };
          };

          # Sonarr
          "sonarr.${config.age.secrets.domain.path}" = {
            forceSSL = true;
            useACMEHost = "primary-domain";
            locations."/" = {
              proxyPass = "http://127.0.0.1:8989";
              proxyWebsockets = true;
            };
          };

          # Radarr
          "radarr.${config.age.secrets.domain.path}" = {
            forceSSL = true;
            useACMEHost = "primary-domain";
            locations."/" = {
              proxyPass = "http://127.0.0.1:7878";
              proxyWebsockets = true;
            };
          };

          # Lidarr
          "lidarr.${config.age.secrets.domain.path}" = {
            forceSSL = true;
            useACMEHost = "primary-domain";
            locations."/" = {
              proxyPass = "http://127.0.0.1:8686";
              proxyWebsockets = true;
            };
          };

          # Prowlarr
          "prowlarr.${config.age.secrets.domain.path}" = {
            forceSSL = true;
            useACMEHost = "primary-domain";
            locations."/" = {
              proxyPass = "http://127.0.0.1:9696";
              proxyWebsockets = true;
            };
          };

          # Jellyseerr
          "jellyseerr.${config.age.secrets.domain.path}" = {
            forceSSL = true;
            useACMEHost = "primary-domain";
            locations."/" = {
              proxyPass = "http://127.0.0.1:5055";
              proxyWebsockets = true;
            };
          };

          # Deluge
          "deluge.${config.age.secrets.domain.path}" = {
            forceSSL = true;
            useACMEHost = "primary-domain";
            locations."/" = {
              proxyPass = "http://127.0.0.1:8112";
              proxyWebsockets = true;
            };
          };

          # FlareSolverr
          "flaresolverr.${config.age.secrets.domain.path}" = {
            forceSSL = true;
            useACMEHost = "primary-domain";
            locations."/" = {
              proxyPass = "http://127.0.0.1:8191";
              proxyWebsockets = true;
            };
          };
        })
      ];
    };

    # ACME
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "${config.base.username}@${config.age.secrets.domain.path}";
        #server = "https://acme-v02.api.letsencrypt.org/directory"; # Changed to production
        reloadServices = ["nginx"];
        environmentFile = config.age.secrets.cloudflare.path;
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
      };
      certs."primary-domain" = {
        domain = "*.${config.age.secrets.domain.path}";
        extraDomainNames = [
          config.age.secrets.domain.path
        ];
        dnsProvider = "cloudflare";
      };
    };
  };
}
